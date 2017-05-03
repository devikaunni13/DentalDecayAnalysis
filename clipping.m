function CI = clipping(I)
BW = edge(I); 
[r1,c1] = find(BW);
x2 = max(r1);
x1 = min(r1);
W = x2 - x1;
y2 = max(c1);
y1 = min(c1);
H = y2 - y1;
i =1; j =1;
c=zeros(W,H);
    for x=x1:x2;
        for y=y1:y2;
            c(i,j) = I(x,y);
            j=j+1;
        end
        i=i+1;
        j=1;
    end
CI = c/256;
%imshow(CI);
