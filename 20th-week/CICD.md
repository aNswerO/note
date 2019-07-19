# <h1 id="top">CI/CD：</h1>
### <a href="#1">1. CI/CD</a>
### <a href="#2">2. 常见的代码部署方式</a>


## <h2 id="1">CI/CD：</h2>
&emsp;&emsp;**CI/CD提供了一个优秀的DevOps环境，可以大幅提高开发团队的开发效率**
+ **持续集成（Continuous Integration）：**  
&emsp;&emsp;频繁地将代码集成到主干，将软件中个人研发的部分向软件整体交付  
    + **持续集成的好处：**  
    ```
        每完成一点更新就集成到主干，可以快速发现错误，定位错误也变得比较容易  

        防止分支大幅度偏离主干，若集成不够频繁，同时主干又在不断更新，会导致以后的集成难度变大
    ```
    + **持续集成的目的：**  
    ```
        让产品在保持高质量的同时，还可以快速迭代
    ```
    + **持续集成的核心措施：**  
    ```
        代码集成到主干之前必须通过自动化测试，只要有一个测试用例失败，就不能集成
    ```
+ **持续交付（Continuous delivery）：**  
&emsp;&emsp;频繁地将软件的新版本交付给质量团队或用户，以供评审；若评审通过，代码就进入生产阶段；持续交付在持续集成的基础上，将集成后的代码部署到更贴近真实运行环境的类生产环境中  
    + **持续交付的目的：**
    ```
        持续交付可看做持续集成的下一步，且其优先于整个产品生命周期的软件部署，它强调的是不管怎样更新，软件都是随时可以交付的
    ```
+ **持续部署（Continuous Deployment）：**
&emsp;&emsp;持续部署是持续交付的下一步，指的是代码通过评审后，自动部署到生产环境中  
    + **持续部署的前提：**
    ```
        能自动完成测试、构建、部署等步骤
    ```  
    + **持续部署的目标：**
    ```
        代码是随时可以部署的，可以进入生产阶段
    ```
## <h2 id="1">常见的代码部署方式：</h2>
1. 蓝绿部署：  
&emsp;&emsp;指在旧版本代码不停的情况下，在另外一个环境部署新版本进行测试，测试通过后再将用户的流量切换至新版本，观察一段时间，若出现异常则切换回旧版本
    + 特点：业务无中断，升级风险相对较小；只有一套正式环境在线

    + 适用场景：
    ```
        蓝绿部署对于增量升级有较好的支持，但对于涉及数据表结构变更等不可逆转的升级，并不合适，需要结合业务逻辑以及数据迁移和回滚的策略才能完全满足需求
    ```

2. 灰度发布：
&emsp;&emsp;指在原版本可用的情况下，同时部署一个新版本的应用，用来测试新版本的性能和表现，以保障整体系统稳定的情况下尽早发现问题并及时进行调整
    + 特点：可以保证整体系统的稳定，在初始灰度时就可以发现问题并进行调整
    + 使用场景：
    ```
        老版本不停止，多一套新版本，不同版本的应用共存

        按照用户设置路由权重，大部分用户维持使用老版本，其余用户尝试新版本

        经常与A/B测试一起使用，用于测试多种方案
    ```
3. 滚动发布：  
&emsp;&emsp;先取出一个或几个服务器停止服务，并进行更新，更新后再将其投入使用，之后在剩余的服务器中再取出一部分进行更新，重复此步骤，直到集群中所有实例都更新为新版本
4. A/B测试：
&emsp;&emsp;同时运行两个APP环境，用来测试应用功能表现的方法，例如可用性、受欢迎程度和可见性等
    + 特点：
    ```
        有两套正式环境在线
    ```


## <a href="#top">回到顶部</a>