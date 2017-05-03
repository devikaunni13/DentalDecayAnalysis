function upd = td(F)
upd = 0;
wbar = waitbar(0,'Initializing, please wait...');
WT = strcat(F,'\train.dat');
if exist(WT, 'file')
    delete(WT);
end
dirInfo = dir(F);
MD = [dirInfo.isdir];
dirNames = {dirInfo(MD).name};
n = length(dirNames);
ftd = fopen(WT,'w');
%M = zeros(n-2,6);
for i=1:n
    vv = ceil((i/n));
    waitbar(vv,wbar,sprintf('Generate training data  %d%%...',vv*100));
    ign = {'.','..'};
    if strcmp(dirNames(i),ign) == 0;
        fc=strcat(F,'\',dirNames{i});
        finfo = dir(fc);
        MF=[finfo.isdir];
        fnames={finfo(~MF).name};
        u=length(fnames);
        c=0;
        for j=1:u
            pfile = strcat(fc,'\',fnames{1});
            I = imread(pfile);
            GR=rgb2gray(I);
            GRAY=dimension(GR);
			CRIM=clipping(GRAY);
			O = getoffset;
			GLCM = graycomatrix(CRIM,'Offset',O);
			stats = graycoprops(GLCM);
			CT = stats.Contrast;
			CO = stats.Correlation;
			EN = stats.Energy;
			HM = stats.Homogeneity;
			ET = entropy(CRIM);
			d1 = mean(CT);
			d2 = mean(CO);
			d3 = mean(EN);
			d4 = mean(HM);
			d5 = mean(ET);
            d6 = psnr_value(CRIM);
            M(j,:) = [d1,d2,d3,d4,d5,d6];
            c=c+1;
        end
        if c>1
           M = mean(M);
        end
        fprintf(ftd,'%d\t%d\t%d\t%d\t%d\t%d\n',M);
    end
end
fclose(ftd);
close(wbar);
upd=1;