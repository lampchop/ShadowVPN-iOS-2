UI documentation
## Main UI draft

![alt main ui](https://raw.githubusercontent.com/udo-tech-team/ShadowVPN-iOS-2/master/docs/shadowbit-dev4.jpg)

This is not a beautiful ui draft but just to demenstrate the interactions between user interfaces.

主要的界面由3部分组成。
1. 主界面，标记为1)
2. 扫码添加配置界面，标记为2)
3. 手动添加配置界面，标记为3)

## 各界面内的操作有以下几种：
### 主界面 1)
app 打启动后的界面
- "+"操作。点开后，弹出下拉菜单，供选择的有两项：
    - Scan QR img. 即扫描图片二维码添加配置
    - Manually Add. 即手动添加配置
- 'i'操作。即点开某个配置的编辑页面，跳到界面3)
- 'V'操作。即选中列表中的某项配置，选中后会在对应的配置前打勾
- 'Status'操作。"Status"右边有个开关，能够启动或关闭app

### 扫码界面 2)
在主界面点"+"后选择扫码后跳到的界面
- '<' 左上方，可回退到主界面，即放弃扫码
- 'Scan from file' 从文件中扫描手机中的本地图片二维码
- 'Back' 返回，同样回到主界面，放弃扫码

### 手动添加、编辑配置界面 3)
主界面点'i' icon或点"+"后选择手动添加配置后跳到的界面
- '<' 左上方，可回退到主界面，即放弃添加配置
- 'save' 即保存已添加的配置
- 'Delete this ...' 删除该配置
