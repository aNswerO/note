## 认证服务keystone：
+ 功能：
  + 用户身份验证：系统需要知道用户是不是合法用户；所以需要keystone对用户进行管理与保存，如，管理用户相关的tenant、role、group、domain等，用户credential的存放、验证和令牌管理等
  
  + 服务目录列表：用户需要知道系统的服务目录；所以需要keystone提供服务目录的管理，包括service、endpoint等
+ 涉及的概念：
    + user：使用OpenStack的用户

    + Credential：用户证据；用来证明用户身份的证据，可以是用户名和密码、用户名和API key、或者一个Keystone分配的token
    + Authentication：身份验证；验证用户身份的过程。Keystone 服务通过检查用户的 Credential 来确定用户的身份。最开始，使用用户名/密码或者用户名/API key作为credential。当用户的credential被验证后，Kestone 会给用户分配一个 authentication token 供该用户后续的请求使用
    + Service服务：一个OpenStack服务，比如Nova、Swift或者Glance等。每个服务提供一个或者多个 endpoint 供用户访问资源以及进行操作。
    + endpoint：端点；一个网络可访问的服务地址，通过它你可以访问一个服务，通常是个URL地址。不同的region有不同的service endpoint。endpoint也可告诉OpenStack service去哪里访问特定的servcie。比如，当Nova需要访问Glance服务去获取image时，Nova通过访问Keystone拿到Glance的endpoint，然后通过访问该endpoint去获取Glance服务。我们可以通过Endpoint的region属性去定义多个region。Endpoint按使用对象分为三类：
        + public：公共端点

        + internal：私有端点
        + admin：管理端点
    + tenant：租户；可以理解为一个人、项目或者组织拥有的资源的合集。在一个租户中可以拥有很多个用户，这些用户可以根据权限的划分使用租户中的资源
    + role：角色；用于分配操作的权限，角色可以被指定给用户，使得该用户获得角色对应的操作权限
    + token：令牌；一串字符串或比特值，用来作为访问资源的记号，token中含有可访问资源的范围和有效时间
+ keystone与其他组件的交互流程：
>以用户创建一个虚拟机为例
  
![avagar](https://github.com/aNswerO/note/blob/master/16th-week/pic/OpenStack%E6%9C%8D%E5%8A%A1%E7%BB%84%E4%BB%B6/keystone%E4%BA%A4%E4%BA%92%E6%B5%81%E7%A8%8B.png)  
+ keystone的两个服务：
    + admin：
        + 提供给管理者（administrator）使用

        + 绑定端口：35357
    + main： 
        + 提供给非管理者（public）使用

        + 绑定端口：5000
