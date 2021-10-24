# Chapter1 - Django Overview by developing a blog
## Install Django
```
pip3 install Django~=3.0.4
```
## Init with command
```
mkdir projects  # make a dir for all projects
cd projects
django-admin startproject mysite    # Init a django project
```
## Folder Structure
In folder `mysite`
- manage.py: the python file to interact with django project. It is a simple wrapper of django-admin, which you don't need to edit.
In folder `mysite/mysite`
- __init__.py: an empty file to tell python this is a module
- asgi.py: settings to run application with ASGI(Async Server Gateway Interface)
- wsgi.py: settings to run application with WSGI(Web Server Gateway Interface)
- urls.py: url patterns here is mapped to views
- settings.py: setting files that contains initial config for your project. A SQLite database is also configured here.

## Run Initial Database Settings
In top folder, run `python3 manage.py migrate`
This will migrate some of initial table to SQLite Database.

## Running develop server
`python3 manage.py runserver`
Then in your browser, type http://127.0.0.1:8000/.
If everything's ok, you will see the welcome page of django

## settings.py
Here are some import segments of settings.py
```
DEBUG = True # If True, Django will print detailed error message. Turn it off in production, Django will return standard error pages like 404.html

ALLOWED_HOSTS = [] # If DEGUG=True, it doesn't work, else you have to add your domain or host in the list to make the site visiable.

INSTALLED_APPS = [  # which app to activate for django procject
    'django.contrib.admin',         # An admin site
    'django.contrib.auth',          # An authentication framework
    'django.contrib.contenttypes',  # A framework to handle content types
    'django.contrib.sessions',      # A session framework
    'django.contrib.messages',      # A messageing framework
    'django.contrib.staticfiles',   # A framework to manage static files
]

MIDDLEWARE = ['something'] # middleware to use
DATABASES = ['something'] # config database, default is an SQLite database
LANGUAGE_CODE = "" # default language coding
```

## starting an app
A Django project will contains a few apps. You need to start an app and write code for that
We are starting an app called blog
```
python3 manage.py startapp blog
```
then `cd blog`, you will see the files
- admin.py: you register models to include in django admin page here
- apps.py: you write configrations here
- migrations: database migration files are here
- models.py: data model for your app. You define models here
- tests.py: you add test code here
- views.py: you write views here, which is your application logic. Each views can receives HTTP requests, process it and return a response.

## Design the blog data schema
The first step to develop an app is always design the data model.
- Your model should subclass django.db.models.Model. Each field of your class is a database field. 
- Django will create the table in database when you use migrate.
- Django will provide you with easy APIs to query objects easily.
This is the blog model
```
from django.db import models
from django.utils import timezone
from django.contrib.auth.models import User

# Create your models here.
class Post(models.Model):
    STATUS_CHOICES = (
        ('draft', 'Draft'),
        ('published', 'Published')
    )
    # title is CharField, which translates into a VARCHAR in SQL database
    title = models.CharField(max_length=500)
    # Slug Field is used in URLs. It just contains letters, numbers, underscores or hyphens.
    # If you input 'This is my title', it may be converted into 'this-is-my-title'
    slug = models.SlugField(max_length=250,
                            unique_for_date='publish'
                            )
    # Author, which is a ForeignKey of table User(Django's integrated User management module)
    author = models.ForeignKey(User,
                               on_delete=models.CASCADE,
                               related_name='blog_posts')
    body = models.TextField()
    publish = models.DateTimeField(default=timezone.now)
    created = models.DateTimeField(auto_now_add = True)
    updated = models.DateTimeField(auto_now=True)
    # choices of status is limited to STATUS_CHOICES. Each item of STATUS_CHOICES is (A,B), where A is used in database, B is for human read
    status = models.CharField(max_length=10, choices=STATUS_CHOICES)
    # Some meta data of database, we specify desc order of publish when querying database
    class Meta:
        ordering = ('-publish',)

    def __str__(self):
        return f'{self.title} (by {self.author})'
```

## Activate your application
Activate blog by adding `blog.apps.BlogConfig` into `INSTALLED_APPS`
```
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'blog.apps.BlogConfig'
]
```

## Create and apply migrations
```
python3 manage.py makemigrations blog
python3 manage.py migrate
```
This will migrate model `blog` to database.
If you want to check what it did, run
```
python3 manage.py sqlmigrate blog 0001
```

## Create a superuser
To manage database in admin page, you need to create a super user
```
python3 manage.py createsuperuser
```
and follow the instructions.

## Start the server and explore the admin page
```
python3 manage.py runserver
```
then open the `http://127.0.0.1:8000/admin/` and login with admin account. Explore it.

## Add blog to admin
edit `admin.py` of blog
```
from django.contrib import admin
from .models import Post
# Register your models here.
admin.register(Post)
```
Then restart the server and check again.

## Customize the way models are displayed
Edit `admin.py` of blog
```
from django.contrib import admin
from .models import Post
# Register your models here.
@admin.register(Post)
class PostAdmin(admin.ModelAdmin):
    list_display = ('title', 'slug', 'author', 'publish', 'status')
```
Restart the server.

## More customed display
```
from django.contrib import admin
from .models import Post
# Register your models here.
@admin.register(Post)
class PostAdmin(admin.ModelAdmin):
    list_display = ('title', 'slug', 'author', 'publish', 'status')
    list_filter = ('status', 'created', 'publish', 'author')
    search_fields = ('title', 'body')
    prepopulated_fields = {'slug': ('title',)}
    raw_id_fields = ('author',)
    date_hierarchy = 'publish'
    ordering = ('status', 'publish')
```
For what they means, see https://docs.djangoproject.com/en/3.2/ref/contrib/admin/

## ORM APIs and QuerySets
- Django provides a set of easy-to-use APIs for Model.
- Its ORM(object-relational mapping) is compatible with multiple database.
- The result of ORM is bases on QuerySet.
Now open python shell with `python3 manage.py shell`
```
>>> from django.contrib.auth.models import User
>>> from blog.models import Post
>>> user = User.objects.get(username='admin')   # query object from database
>>> print(user)
admin
>>> post = Post(title='Another post', slug='another-post', body='example body', author=user)
>>> post.save() # add object to database
```
There are other methods:
```
>>> all_posts = Post.objects.all()  # query all objects
>>> all_posts
<QuerySet [<Post: Another post (by admin)>, <Post: WilliamCode start (by admin)>]>
```
```
>>> Post.objects.filter(publish__year=2021)
<QuerySet [<Post: Another post (by admin)>, <Post: WilliamCode start (by admin)>]>
>>> Post.objects.filter(author__username='admin')
<QuerySet [<Post: Another post (by admin)>, <Post: WilliamCode start (by admin)>]>
```
```
>>> Post.objects.filter(author__username='admin').exclude(title__startswith='Ano')
<QuerySet [<Post: WilliamCode start (by admin)>]>
>>> Post.objects.filter(author__username='admin').order_by('-title')
<QuerySet [<Post: WilliamCode start (by admin)>, <Post: Another post (by admin)>]>
>>> Post.objects.filter(author__username='admin').order_by('title')
<QuerySet [<Post: Another post (by admin)>, <Post: WilliamCode start (by admin)>]>
```
```
>>> post = Post.objects.get(id=1)
>>> post.delete()
```
Full version API is located at: https://docs.djangoproject.com/en/3.2/ref/models/querysets/

## When the query is excuted
For efficiency, QuerySet is not excuted until
- The first time you iterate over them
- When you slice them, like `Post.objects.all()[:3]`
- When you pickle or cache them
- When you explictly convert them with list()
- When you call len() or repr()
- When you test them in a statement like bool(), or, and , if

## Create model managers
Default model manager is objects, which you call in `Post.objects.all()`
- If you don't provide manager in model class, a `objects` is added by django.
- If you specify one manager in model class, it is(or they are) used as default.
- If you want to add your own and preserve the default `objects`, explictly define it.
This is an example of defining new manager `published` and preserving the default `objects`
```
class PublishedManager(models.Manager):
    def get_queryset(self):
        return super().get_queryset().filter(status='published')

class Post(models.Model):
    # ......
    objects = models.Manager()  # The default manager
    published = PublishedManager()  # Out custom manager

```
Run `python3 manager.py shell`
The result is 
```
>>> Post.objects.all()
<QuerySet [<Post: Another post (by admin)>, <Post: WilliamCode start (by admin)>]>
>>> Post.published.all()
<QuerySet [<Post: WilliamCode start (by admin)>]>
```
To see more, visit https://docs.djangoproject.com/en/3.2/topics/db/managers/

## Create a view to display post list and post detail
- Views always takes `request` parameter(Which is a HTTPRequest).
- render() will render the templete with the given context.
There are two views
```
from django.shortcuts import render
from .models import Post
from django.shortcuts import get_object_or_404

def post_list(request):
    posts = Post.published.all()
    return render(request, 'blog/post/list.html', {'posts': posts})

def post_detail(request, year, month, day, post):
    post = get_object_or_404(Post, slug=post, status='published', publish__year=year, publish__month=month, publish__day=day)
    return render(request, 'blog/post/detail.html', {'post': post})
```

## Add URL pattern for views
- URL is a pattern(can be a regex). 
- You should map URL to views in urls.py. Django will call it.
Now create a new file in blog and edit it
```
from django.urls import path
from . import views

app_name = 'blog'

urlpatterns = [
    # post views
    path('', views.post_list, name='post_list'),
    path('<int:year>/<int:month>/<int:day>/<slug:post>',
         views.post_detail,
         name='post_detail'),
]
```
- `'<int:year>/<int:month>/<int:day>/<slug:post>'` is a pattern which requires year,month,day to be int and post to be slug
- you can also use `<username>` to capture a value as string into variable username
- If path is not enough, you can use re_path() to match URL with regex
- For more info, visit https://docs.djangoproject.com/en/3.2/ref/urls/


Now edit mysite/urls.py
```
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('blog/', include('blog.urls', namespace='blog'))
]
```

## Canonical URLs for models
Add the function for model Post
```
class Post(models.Model):
    # ......
    def get_absolute_url(self):
        return reverse('blog:post_detail', args=[self.publish.year, self.publish.month, self.publish.day, self.slug])
```
- This function get url from given parameter by reverse
- in `blog:post_detail` blog is the namespace we configured in mysite/urls.py, post_detail is the url name.
- We will need to call it from template later

## Create templates for views
Create the following folders in `blog` app folder
```
templates/
    blog/
        base.html
        post/
            list.html
            detail.html
```
- We will write basic structure of the page in base.html. list.html and detail.html will inherit from it.
- Detail of templete is located at https://docs.djangoproject.com/en/3.2/topics/templates/
Edit base.html
```
{% load static %}
<!DOCTYPE html>
<html>
<head>
    <title>{% block title %}{% endblock %}</title>
    <link href="{% static "css/blog.css" %}" rel="stylesheet">
</head>
<body>
    <div id="content">
        {% block content %}
        {% endblock %}
    </div>
    <div id="sidebar">
        <h2>My Blog</h2>
        <p>This is my blog</p>
    </div>
</body>
</html>
```
In the code
- {% load static %} tells Django to load static template tags provided by `django.contrib.staticfiles`. After that you can use {% static %} tag to import any static files like `blog.css`
- The default static folder is configured in settings.py. Now create a folder `static/` in the `blog` folder. Create a `css/` in `static/` and edit the blog.css file:
```
body{margin:0;padding:0;font-family:helvetica,sans-serif}a{color:#00abff;text-decoration:none}h1{font-weight:400;border-bottom:1px solid #bbb;padding:0 0 10px 0}h2{font-weight:400;margin:30px 0 0}#content{float:left;width:60%;padding:0 0 0 30px}#sidebar{float:right;width:30%;padding:10px;background:#efefef;height:100%}p.date{color:#ccc;font-family:georgia,serif;font-size:12px;font-style:italic}.pagination{margin:40px 0;font-weight:700}label{float:left;clear:both;color:#333;margin-bottom:4px}input,textarea{clear:both;float:left;margin:0 0 10px;background:#ededed;border:0;padding:6px 10px;font-size:12px}input[type=submit]{font-weight:700;background:#00abff;color:#fff;padding:10px 20px;font-size:14px;text-transform:uppercase}.errorlist{color:#c03;float:left;clear:both;padding-left:10px}.comment{padding:10px}.comment:nth-child(even){background:#efefef}.comment .info{font-weight:700;font-size:12px;color:#666}
```

Now edit `post/list.html`
```
{% extends "blog/base.html" %}
{% block title %} My Blog{% endblock %}
{% block content %}
    <h1>My Blog</h1>
    {% for post in posts %}
        <h2>
            <a href="{{ post.get_absolute.url }}">
                {{ post.title }}
            </a>
        </h2>
        <p class="date">
            Published {{ post.publish }} by {{ post.author }}
        </p>
    {{ post.body | truncatewords:30 |linebreaks }}
    {% endfor %}
{% endblock %}
```
- {% extends %} tag tells Django to inherit from base.html. Then we will fill block title and content

Then please restart the server and open the page http://127.0.0.1:8000/blog/ t visit the page


Then we will edit the detail.html
```
{% extends "blog/base.html" %}
{% block title %} {{ post.title }} {% endblock %}
{% block content %}
    <h1>{{ post.title }}</h1>
    <p class="date">{{ post.publish }} by {{ post.author }}</p>
    {{ post.body | linebreaks }}
{% endblock %}
```

## Add pagination
If there are many posts, it will be inrational to put it in one page. Now edit views.py to add the paginator
```
def post_list(request):
    posts = Post.published.all()
    paginator = Paginator(posts, 3)
    page = request.GET.get('page')
    try:
        posts = paginator.page(page)
    except PageNotAnInteger:
        posts = paginator.page(1)
    except EmptyPage:
        posts = paginator.page(paginator.num_pages)
    return render(request,
                  'blog/post/list.html',
                  {'page': page,
                   'posts': posts})
    # return render(request, 'blog/post/list.html', {'posts': posts})
```

Then create a new file named `pigination.html` in `template`, edit it:
```
<div class="pagination">
    <span class="'step-links">
        {% if page.has_previous %}
            <a href="?page={{ page.previous_page_number }}">&lt;Previous</a>
        {% endif %}
        <span class="current">
            Page {{ page.number }} of {{ page.paginator.num_pages }}
        </span>
        {% if page.has_next %}
            <a href="?page={{ page.next_page_number }}">Next&gt;</a>
        {% endif %}
    </span>
</div>
```
- This template take a parameter page and render the paginator on the page
- Next, import it in `list.html`
```
{% block content %}
    ......
    {% include "pagination.html" with page=posts %}
{% endblock %}
```

Now you can visit the list again, each page will have at most 3 posts.

## Class based views
- views is a function by now. But a class can also be callable and covers more advantages in terms of organizing and reusing code.
- We will use a ListView here to alter post_list.
- For more detail, visit https://docs.djangoproject.com/en/3.2/ref/class-based-views/
Now add a new view in views.py
```
from django.views.generic.list import ListView

def PostListView(ListView):
    queryset = Post.published.all()
    context_object_name = 'posts'
    paginate_by = 3
    template_name = 'blog/post/list.html'
```
- queryset tells ListView what queryset to use
- context_object_name tells what name to use for the queryset in context, which will be passed to template
- paginate_by tells how many records in a page
- template_name tells which template to render
- To see more about what the attributes mean, visit https://docs.djangoproject.com/en/3.2/ref/class-based-views/flattened-index/#ListView
Modify the urls.py
```
urlpatterns = [
    # post views
    # path('', views.post_list, name='post_list'),
    path('', views.PostListView.as_view(), name='post_list'),
    path('<int:year>/<int:month>/<int:day>/<slug:post>',
         views.post_detail,
         name='post_detail'),
]
```
Because pagenator of ListView pass `page_obj` as pagination result to template, we need to modify pagination in `list.html`
```
{% include "pagination.html" with page=page_obj %}
```
Then visit the list. You will see the same page.

*****
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>

# Chapter two