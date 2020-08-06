## ansible批量管理服务器同步web服务

1.建立一个文件

  vim   /etc/ansible/roles/tongbu/tasks/main.yml

```
---
- name : 同步文件
  synchronize :
    src  : /software
    dest : /
    delete : yes
    #rsync_timeout : 10
  register : reload

- name : 创建链接目录
  file :
    state : directory
    path : /etc/nginx/{{ item.dir }}
  with_items :
    - { dir : 'conf' }
    - { dir : 'kis' }

- name : 域名证书及配置文件软链接
  file :
    state : link
    src : /software/{{ item.name }}
    path : /etc/nginx/{{ item.dir }}/{{ item.name }}
  register : result
  with_items :
    - { dir : 'conf', name : '域名证书' }
    - { dir : 'kis', name : '站点配置文件' }

- name : 检测Web应用
  stat :
    path : /usr/bin/openresty
  register: p

- name : 修改文件夹属主
  shell : chown nginx. /etc/nginx/{{ item.dir }} -R
  args :
    warn: False
  when : result is changed and p.stat.exists == False
  with_items :
    - { dir : 'conf' }
    - { dir : 'kis' }

- name : 重载nginx配置
  service :
    name : nginx
    state : reloaded
  when : reload is changed and p.stat.exists == False

- name : 重载Openresty配置
  command: /usr/bin/openresty -s reload
  when : p.stat.exists

```
2. 建一个剧本文件

vim /etc/ansible/tb.xml

   ```
   ---
     - hosts : China
       remote_user : root
       roles:
         - tongbu
   ```

3,定义的组是China，需要在/etc/ansible/hosts 文件里新建主机组

   最后就是执行剧本

```
sudo ansible-playbook /etc/ansible/tb.xml
```

可以创建别名，这样方便每次执行

```
alias tb=' sudo ansible-playbook /etc/ansible/tb.xml'
```

