# django-rest-framework

## 一、安装及配置

### 1. 安装软件包

```bash
pip install django==2.2
pip install djangorestframework
pip install mysqlclient
```


### 2. 创建project和app

```bash
djang-admin startproject tutorial
cd tutorial
python manage.py startapp user
```

### 3. 注册应用


```bash
INSTALLED_APPS = [
	...
    'rest_framework',
	'user.apps.UserConfig',
]
```

## 二、序列化与反序列化

### 1. 序列化

创建`user/models.py`

```python
from django.db import models


class User(models.Model):
    id = models.AutoField(primary_key=True)
    username = models.CharField(max_length=128)
    email = models.EmailField(blank=False)
    phone = models.CharField(max_length=128, blank=False)

    class Meta:
        db_table = 'user'
```

数据迁移

```bash
python manage.py makemigrations user
python manage.py migrate user
```

创建`user/serializers.py`,继承`serializers.Serializer`,需要重写`create()`和`update()`方法

```python
from rest_framework import serializers
from .models import User

class UserSerializer(serializers.Serializer):
    id = serializers.IntegerField(read_only=True)
    username = serializers.CharField(max_length=128)
    email = serializers.EmailField(required=False)
    phone = serializers.CharField(required=False)

    def create(self, validated_data):
        return User.objects.create(**validated_data)

    def update(self, instance, validated_data):
        instance.username = validated_data.get('username', instance.username)
        instance.email = validated_data.get('email', instance.email)
        instance.phone = validated_data.get('phone', instance.phone)

        instance.save()
        return instance

```

配置`user/view.py`

```python
from django.http import JsonResponse
from rest_framework.views import APIView
from .serializers import UserSerializer
from .models import User


class UserListView(APIView):

    def get(self, requests):
        users = User.objects.all()
        serializer = UserSerializer(users, many=True)
        return JsonResponse(serializer.data, safe=False)
```

配置`user/url.py`

```python
from django.urls import path
from .views import UserListView

urlpatterns = [
    path('user/', UserListView.as_view(), name="user-list"),
]
```

优化，使用`rest_framework`升级的请求对象`Response`进行返回数据

```python
from rest_framework.views import APIView
from rest_framework.response import Response
from .serializers import UserSerializer
from .models import User


class UserListView(APIView):

    def get(self, requests):
        users = User.objects.all()
        serializer = UserSerializer(users, many=True)
        return Response(serializer.data)
```

单个对象信息访问

`view.py`

```python
from django.http import Http404
from rest_framework.views import APIView
from rest_framework.response import Response
from .serializers import UserSerializer
from .models import User

class UserDetailView(APIView):

    def get_object(self, pk):
        try:
            return User.objects.get(pk=pk)
        except User.DoesNotExist:
            raise Http404

    def get(self, request, pk):
        user = self.get_object(pk=pk)
        serializer = UserSerializer(user)
        return Response(serializer.data)

```

增加`url.py`配置

```python
from django.urls import path
from .views import UserListView, UserDetailView

urlpatterns = [
    path('user/', UserListView.as_view(), name="user-list"),
    path('user/<int:pk>/', UserDetailView.as_view(), name="user-detail"),
]
```

将`serializers.Serializer` 更换为 `serializers.ModelSerializer`，通过数据库模型进行序列化。

```python
from rest_framework import serializers
from .models import User


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        # 指定字段
        fields = ['id', 'username', 'email', 'phone']
        # 所有字段
        # fields = '__all___'
        # 排除某些字段
        # exclude = ['id']
        # 额外参数
        # extra_kwargs = {
        #   'username': { 'required': True, 'max_length': 128}    
        #}
```

### 2. 反序列化

反序列化就是将用户的请求(`post`,`put`)，进行数据校验，通过序列化器，反向到数据库中创建，或更新数据。

