function c = get_some_colors()
%While running the trace analysis tool, the user may import many traces.  However,
%matlab only uses a few default colors.  
%The colors listed in this function are used as the default colors.

c =[0.77254901960784   0.54117647058824   1.00000000000000;
   0.10588235294118   0.73725490196078   0.61176470588235;
   0.72549019607843                  0   0.36078431372549;
   0.74509803921569   0.48627450980392   0.48627450980392;
                  0   0.47843137254902   0.95686274509804;
   0.73333333333333   0.65882352941176   0.72156862745098;
   0.61568627450980   0.61568627450980   0.30980392156863;
   0.60784313725490                  0                  0;
   0.29411764705882   0.58823529411765   0.58823529411765;
   0   0.45882352941176                  0
   1.00000000000000   0.50196078431373   0.25098039215686;
                  0   1.00000000000000                  0;
   0.50196078431373   0.50196078431373   0.75294117647059;
   1.00000000000000                  0   1.00000000000000;
   1.00000000000000                  0   0.50196078431373;
                  0   0.50196078431373   1.00000000000000;
   0.50196078431373   0.50196078431373                  0;
   0.25098039215686   0.50196078431373   0.50196078431373;
   0.50196078431373   0.50196078431373   0.50196078431373;
   0.61176470588235   0.30588235294118   0.30588235294118;
   1.00000000000000   0.50196078431373   0.25098039215686;
                  0   1.00000000000000                  0;
   0.50196078431373   0.50196078431373   0.75294117647059;
   1.00000000000000                  0   1.00000000000000;
   1.00000000000000                  0   0.50196078431373;
                  0   0.50196078431373   1.00000000000000;
   0.50196078431373   0.50196078431373                  0;
   0.25098039215686   0.50196078431373   0.50196078431373;
   0.50196078431373   0.50196078431373   0.50196078431373;
   0.61176470588235   0.30588235294118   0.30588235294118
	0.77254901960784   0.54117647058824   1.00000000000000;
   0.10588235294118   0.73725490196078   0.61176470588235;
   0.31764705882353   0.65882352941176   1.00000000000000;
   0.72549019607843                  0   0.36078431372549;
   0.74509803921569   0.48627450980392   0.48627450980392;
                  0   0.47843137254902   0.95686274509804;
   0.73333333333333   0.65882352941176   0.72156862745098;
   0.61568627450980   0.61568627450980   0.30980392156863;
   0.60784313725490                  0                  0;
   0.29411764705882   0.58823529411765   0.58823529411765];
   
c = [c; rand(100,3)];