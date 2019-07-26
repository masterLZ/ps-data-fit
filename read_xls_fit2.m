%%
%方法2使用带常数项的高斯拟合方法
%%
clear;
clc;
close all;
warning off;
isreadhig = 1;
if isreadhig 
    read_hig;
end
%列出文件夹下所有文件
%%
%这里路径需要更改
path = 'E:\oyxp\ps-data\Autocorrelation_data\PsWidth20-Image';
cd(path)
save_path = '..\PsWidth20_lizhan0724';
%%
fileFolder=fullfile(path);
dirOutput = dir(fullfile(fileFolder,'*.xls'));
filenames = {dirOutput.name};
figure,
FPWM_1ps = [];
table_name_1ps = [];
FPWM_10ps = [];
table_name_10ps = [];
for i = 1:length(filenames)
    file = filenames{i};
    head = strsplit(file,'.x');
    head_A = head{1};
   %%读取年份
    head = strsplit(head_A,'-');
    year = str2double(head{1});
    month = str2double(head{2});
    %只要2019年数据
    if(year >= 2019 && month>=4)
        head_B = strsplit(head_A,'--');
        if(length(head_B)==1)
            plus_Width = str2double(head{5});
            if (plus_Width > 0 && plus_Width <50)
            %有效数据
            
                file_effective = file;
                data = xlsread(file_effective);
                x = data(:,1);
                y = data(:,2);
                
                
                index_20 = find(y>=max(y)*0.3);
                x1 = x(index_20(1));
                x2 = x(index_20(length(index_20)));
                plus_width20 =abs(x2-x1);
%                 x_out = linspace(x1,x2,200);
%                 x_in = x(index_20(1):index_20(length(index_20)));
%                 y_in = y(index_20(1):index_20(length(index_20)));
%                 y_out = interp1(x_in,y_in,x_out,'makima');
%                 x = [x(1:index_20(1)-1)',x_out,x(index_20(length(index_20))+1:length(x))'];
%                 y = [y(1:index_20(1)-1)',y_out,y(index_20(length(index_20))+1:length(y))'];
                h = plot(x,y,'LineWidth',1.5);
                hold on ;grid on;
                title(head_B);               
                
                %先滤波
%                 Fy = fftshift(fft(y));
%                 if(plus_Width>5)
%                     Len = 12;
%                 else
%                     Len = 40;
%                 end
%                 Fy_B = zeros(size(Fy));
%                 mid = round(length(Fy)/2);
%                 Fy_B(mid-Len:mid+Len-1)= Fy(mid-Len:mid+Len-1);
%                 y1 = real(ifft(ifftshift(Fy_B)));
%                 y1(y1<0)=0;
%                 plot(x,y,'LineWidth',1.5);
%                 %
                if(1)
                   f = @(A,xdata) (A(1).*exp(-((xdata-A(2))/A(3)).^2)+A(4));
                   A0 = [1,0,0.5,0.2];
                else 
                    %这里是洛伦兹函数拟合，没有应用，只做研究
                   f = @(A,xdata) A(1).*exp(-((x-A(2))./A(3)).^2)+A(4);
                   A0 = [1,0,0.5,0.2]; 
                end
                
                A1 = lsqcurvefit(f,A0,x,y);
                y1 = f(A1,x);
 
                plot(x,y1,'g','LineWidth',1.5)
                
                if (max(y)/2 > max(y1))
                    fpwm_buffer = find(y>=max(y)/2);
                else
                    if (max(y1) > max(y))
                        fpwm_buffer = find(y1>=max(y1)/2);
                    else
                        fpwm_buffer = find(y1>=max(y)/2);
                    end
                end
                
                fpwm = abs(x(fpwm_buffer(1))-x(fpwm_buffer(length(fpwm_buffer))));
                fpwm_buffer = find(y>=max(y)/2);
                fpwm2 = abs(x(fpwm_buffer(1))-x(fpwm_buffer(length(fpwm_buffer))));
                if (plus_Width<5)
                    FPWM_1ps = [FPWM_1ps;{fpwm2,fpwm,plus_Width}];
                    table_name_1ps = [table_name_1ps;head_B(1)];
                else
                    FPWM_10ps = [FPWM_10ps;{fpwm2,fpwm, plus_Width}];
                    table_name_10ps = [table_name_10ps;head_B(1)];
                end
                
                lable1 = sprintf('origin:%.3f',fpwm2);
                lable2 = sprintf('gussian:%.3f',fpwm);
                legend(lable1,lable2);
                hold off
                str_path = sprintf('%s\\%s+%.3f_%.3f.png',save_path,head_B{1},fpwm2,fpwm);
                saveas(h ,str_path)
            end
        end    
        
        
    end
end
%table_fpwm = table(table_name,FPWM);
write_fpwm_1ps = [table_name_1ps,FPWM_1ps];
str_path = sprintf('%s\\data\\1ps_tale_delta1.xls',save_path);
xlswrite(str_path,write_fpwm_1ps);
write_fpwm_10ps = [table_name_10ps,FPWM_10ps];
str_path = sprintf('%s\\data\\10ps_tale_delta1.xls',save_path);
xlswrite(str_path,write_fpwm_10ps);
%%
clc;
std_1ps = std(cell2mat(FPWM_1ps));
RMS_1ps = std_1ps./mean(cell2mat(FPWM_1ps));
PV_1ps = (max(cell2mat(FPWM_1ps))-min(cell2mat(FPWM_1ps)))./mean(cell2mat(FPWM_1ps));
fprintf('\n1ps 改进前 std=%.3f,RMS=%.3f,PV=%.3f',std_1ps(3),RMS_1ps(3),PV_1ps(3))
fprintf('\n1ps 改进后原始 std=%.3f,RMS=%.3f,PV=%.3f',std_1ps(1),RMS_1ps(1),PV_1ps(1))
fprintf('\n1ps 改进后拟合 std=%.3f,RMS=%.3f,PV=%.3f',std_1ps(2),RMS_1ps(2),PV_1ps(2))
std_10ps = std(cell2mat(FPWM_10ps));
RMS_10ps = std_10ps./mean(cell2mat(FPWM_10ps));
PV_10ps = (max(cell2mat(FPWM_10ps))-min(cell2mat(FPWM_10ps)))./mean(cell2mat(FPWM_10ps));
fprintf('\n10ps 改进前 std=%.3f,RMS=%.3f,PV=%.3f',std_10ps(3),RMS_10ps(3),PV_10ps(3))
fprintf('\n10ps 改进后原始 std=%.3f,RMS=%.3f,PV=%.3f',std_10ps(1),RMS_10ps(1),PV_10ps(1))
fprintf('\n10ps 改进后拟合 std=%.3f,RMS=%.3f,PV=%.3f',std_10ps(2),RMS_10ps(2),PV_10ps(2))
 %writetable(table_fpwm,str_path);