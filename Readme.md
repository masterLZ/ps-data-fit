ps数据处理
分为labview部分和matlab部分

matalb部分：
fit1是减去前100数据均值然后进行高斯拟合
fit2是利用高斯函数加一个常数进行拟合
使用前需要指定PS数据所在位置和最后处理结果所放位置
如果需要hig转伪彩色 read_hig 同样也需要指定位置

新增fit3 计算PWHM时使用（fmax-fmin）/2+fmin的方式替换原来fmax/2
当计算脉宽大于80ps（信号较弱，比如30ps数据）时，对数据进行滤波后重新计算
