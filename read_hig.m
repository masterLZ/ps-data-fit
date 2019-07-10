clear;
clc;
close all;
warning off;
%列出文件夹下所有文件
path = 'E:\oyxp\ps-data\Autocorrelation_data\PsWidth20-Image';
cd(path)
save_path = '..\PsWidth20_lizhan0710';
fileFolder=fullfile(path);
dirOutput = dir(fullfile(fileFolder,'*.HIG'));
filenames = {dirOutput.name};
figure,
for i = 1:length(filenames)
    file = filenames{i};
    head = strsplit(file,'.H');
    head_A = head{1};
    %%读取年份
    head = strsplit(head_A,'-');
    year = str2double(head{1});
    month = str2double(head{2});
    %只要2019年数据
    if(year >= 2019 && month>=4)
        head_B = strsplit(head_A,'--');
        if(length(head_B)==1)
            plus_sidth = str2double(head{5});
            if (plus_sidth > 0 && plus_sidth <40)
                %有效数据
                file_effective = file;
                fprintf('\n%s',head_B{1})
                pic = HigtoUnit16(file_effective);
                fprintf('\n%d',max(max(pic)))
%                 imwrite(pic,[save_path,'\',head_B{1},'.tif'])
                pic = mat2gray(pic);
                pic = medfilt2(pic);
                pic = imgaussfilt(pic);
                [M,N] = size(pic);
                pic = double(pic(:,30:M-30));
               
%                 pic = (pic - mean2(pic))./std2(pic);
                Am = (sum(pic,1));
                Am = (Am-mean(Am))./std(Am);
                % Am = Am./max(Am);
                times = 1:length(Am);
                [~,index] = max(Am);
                times = ((times - index)*0.232)';
                h = imshow(pic,[],'Colormap',jet);
                str_path = [save_path,'\',head_B{1},'.bmp'];
                saveas(h ,str_path)
                save_table = table(times,Am');
                str_path = [save_path,'\',head_A,'.xls'];
                writetable(save_table,str_path);
            end
        end
        
    end
end

%%
function pic = HigtoUnit16 (filename)
    fileID = fopen(filename);
    %先读文件头
    A = fread(fileID,[3,1],'int','l');
    Width = A(2);Height = A(3);
    fseek(fileID,0,'eof');
    %从文档结尾偏移Width*Height*2
    fseek(fileID,-Width*Height*2,'eof');
    pic = fread(fileID,[Width ,Height],'uint16','l');
    pic = uint16(pic');
    fclose(fileID);
end