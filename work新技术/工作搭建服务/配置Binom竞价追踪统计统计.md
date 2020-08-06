# 配置Binom竞价追踪统计统计

[toc]

## 1. 添加广告联盟

![img](https://docs.binom.org/images/start/1-1.png)

1. 点击 **Aff. Networks** 项。
2. 点页面左边的 **Create** 按钮

![aDA0ht.png](https://s1.ax1x.com/2020/08/04/aDA0ht.png)

3. 输入广告联盟的名字（在我们的例子中，就是zeropark）
4.  回传url可以先不用填，等第五步回传设置的时候在配置
5. 点击 **Save**按钮
6. 如果您想添加更多广告联盟，请重复之前的步骤。



## 2. 添加流量源

![img](https://docs.binom.org/images/start/2-1.png)

1. 点击 **Traffic Sources** 项

2. 点击页面左边的 **Create** 按钮

   

![img](https://docs.binom.org/images/start/2-2.png)![img](https://docs.binom.org/images/start/2-2-2.png)

3. 如果您想直接从模板里添加流量源，只需要点 “**Load from template**”按钮。我们的追踪器包含了很多的常见流量源。只需简单搜索就可以找到您想要添加的流量源。
4. 如果模板里面没有您需要的流量源，就直接输入流量源的名字在“name”表单里，例子里的名字是“Facebook”。
5. 如果需要使用token，则需在“**Use tokens**”选项中打钩。这样就能从流量源传输信息到追踪器，比如广告标识、操作系统、渠道标识、设备等信息。在例子中，Facebook没有自己的参数，所以您需要自己手动设置所有参数。
6. 添加必要token，我们就能追踪到age（年龄），gender（性别），ad（广告），account（广告账号）。
7. 点击“**Save button**”按钮保存流量源

![img](https://docs.binom.org/images/start/2-3.png)

## 3. 添加广告

登录广告联盟后台（例子中是Adsimilis）宋词有后台



![img](https://docs.binom.org/images/start/3-1.png)

1. 在搜索框里输入广告名称或者ID，如图中标识1处的“Beauty Boxes Sweeps”。
2. 在广告列表里找到需要的广告并点击，有时候还需要审核，等审核通过才能进行相关广告设置
3. 点击图中3标识处“**Creatives**”标签。
4. 复制“Unique link”下面的链接。

**也就是这里需要到广告后台 获取广告url连接**

```
https://999.v785.cn/pop4/?id1={target}&{source}
```



**然后回到追踪服务器中 点击“Offers”标签**

![img](https://docs.binom.org/images/start/3-2.png)



5. 打开追踪器的“**Offers**”项
6. 点击“**Create**”按钮

![img](https://docs.binom.org/images/start/3-3.png)

7. 输入广告的名字

8. 将从广告联盟中复制的广告链接粘贴到URL框中，在例子中就是 `http://simstrx.com/?a=14857&c=63877&s1=`

9. 在参数“&s1=”后添加{clickid}。当用户点击链接到广告页面的时候，追踪器会生成一个唯一的click ID,当产生转化的时候，广告联盟会回传信息是哪个click ID产生的转化。有些广告联盟不允许用s1作为参数，我们可以在广告链接里用s2来替代，替换后的广告链接就是
    `http://simstrx.com/?a=14857&c=63877&s2={clickid}`

**我这里的实际链接是**

```
https://999.v785.cn/pop4/?id1={target}&{source}&s2={clickid}
```

10. 选择广告的投放的国家

11. 给广告选择一个分组或者新建一个分组，可以根据广告类型或者流量类型来分组。

12. 选择

13. 设置广告的佣金。也可以勾选“Auto”直接获取每个转化带来的佣金，通过在回传连接中设置，具体查看 [这里](https://docs.binom.org/payout-tracking.php)。

14. 点击“**Save**”按钮保存。

## 4. 添加引导页

![img](https://docs.binom.org/images/start/4-1.png)

1. 打开“**Landing pages**”项
2. 点击“**Create**”按钮。

![img](https://docs.binom.org/images/start/4-2.png)

3. 上图3处输入引导页名字
4. 上图4处输入引导页URL地址
5. 为引导页选择一个分组或者创建一个分组，只要点击“**Add new**”。
6. 为引导页选择语言种类。
7. 图中7处输入广告个数（如果一个引导页上有多个广告），或者可以不填。一般来说，一个引导页上都是一个广告。
8. 点击“**Save**”按钮

![img](https://docs.binom.org/images/start/4-3.png)

9. 点击最上面菜单的“**Settings**”，然后页面拉到下面。

![aDVKRx.png](https://s1.ax1x.com/2020/08/04/aDVKRx.png)

10. **复制** 方框中的“Click URL”，插入到引导页中，用户点击这个链接将到达广告页面。如果一个引导页有多个广告，可以使用以下链接：
`http://tracker.com/click.php?lp=1&to_offer=**1**`
`http://tracker.com/click.php?lp=1&to_offer=**2**`

也就是把url复制。然后输入到引导页的url里面

## 5. 回传设置

登录广告联盟后台（例子中是Adsimilis）宋词有后台

找到广告后台里面的url地址复制到追踪服务器里面的回传url里面。也就是第一步填写的地方。

回传url。

```
http://postback.zeroredirect1.com/zppostback/8508c4d1-8c1f-11e9-8a1b-12077332b422?cid={externalid}&payout={payout}
```

## 6. 创建广告系列

![img](https://docs.binom.org/images/start/5-1.png)

1. 打开“**Campaigns**”页面
2. 点击“**Create**”按钮。

![img](https://docs.binom.org/images/start/5-2.png)

3. 输入广告系列名称。
4. 为广告系列选择一个分组或者创建一个分组。
5. 选择一个流量源，在例子中是Facebook
6. 设置每次点击价格，假如价格设置错误了，还可以使用 [Update costs](https://docs.binom.org/update-costs.php) 功能修改成本。

![img](https://docs.binom.org/images/start/5-3.png)

7. 选择是否使用引导页，如果不使用引导页，直接点击“**+ Direct**”按钮。如果要使用引导页，则点击“**+ Lander**”按钮，在弹出来的窗口中可以很容易搜索到所需要的引导页，然后点击选择，他就会出现在广告系列里面。
8. 点击“+ Offer”按钮，跟选择引导页相似的操作选择添加广告。

![img](https://docs.binom.org/images/start/5-4.png)

9. 点击“**Save**”按钮保存广告系列。

![img](https://docs.binom.org/images/start/5-5.png)

10. 复制广告系列URL，这就是最终的Campaign URL，也就是需要在流量平台中买流量时要填的链接，在例子中就是：
    `http://tracker.com/click.php?camp_id=1&key=28z6qx4x2rupso00l06h&age={age}&sex={sex}&ad={ad}&acc={acc}`

我的是下面的url
```
    http://8.210.212.235/click.php?key=q9y7qc9zjlp54u2srvds&cid={cid}&visit_cost={visit_cost}&target={target}&campaign_id={campaign_id}&geo={geo}&keyword={keyword}&source={source}&match={match}&campaign_name={campaign_name}&carrier={carrier}&traffic_type={traffic_type}&visitor_type={visitor_type}
```

​    

最后的效果：

![aDZWAH.png](https://s1.ax1x.com/2020/08/04/aDZWAH.png)



## 7. 广告发布

**在广告联盟后台上操作**

在得到广告系列链接后，可以在流量源发布广告。比如购买20-25岁的女性流量，可以使用以下链接：
`http://tracker.com/click.php?camp_id=1&key=28z6qx4x2rupso00l06h&age=**20-25**&sex=**W**&ad=**ad1**&acc=**testacc123**`
还可以用同样的方法为不同人群或者不同账号发布广告，然后我们可以在统计中看到全部的分组数据。

```
   http://8.210.212.235/click.php?key=q9y7qc9zjlp54u2srvds&cid={cid}&visit_cost={visit_cost}&target={target}&campaign_id={campaign_id}&geo={geo}&keyword={keyword}&source={source}&match={match}&campaign_name={campaign_name}&carrier={carrier}&traffic_type={traffic_type}&visitor_type={visitor_type}
```

