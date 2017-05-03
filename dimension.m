function out_img = dimension (gray_img)
level = graythresh(gray_img);
seg_img = im2bw(gray_img,level);
siz=size(gray_img);
[L num] = bwlabel(seg_img);
    for j = 1:num
        if length(find(L == j)) < 20
            L(L==j) = 0;
        end
    end
    L1 = imdilate(L,ones(3));
    [labe num] = bwlabel(L1);
    box = regionprops(labe,'BoundingBox');
    m_bounv=0;
    n=max(labe(:)); % number of objects
    ObjCell=cell(n,1);
    DIS = 0;
    for j = 1:num
        r_size=  round(box(j).BoundingBox);
        if(m_bounv<(r_size(4)*r_size(3))  )
            m_bounv=r_size(4)*r_size(3);
        end
          idx_x=[r_size(1)-2 r_size(1)+r_size(3)+2];
          idx_y=[r_size(2)-2 r_size(2)+r_size(4)+2];
          if idx_x(1)<1, idx_x(1)=1; end
          if idx_y(1)<1, idx_y(1)=1; end
          if idx_x(2)>siz(2), idx_x(2)=siz(2); end
          if idx_y(2)>siz(1), idx_y(2)=siz(1); end

          % Crop the object and write to ObjCell
          ObjCell{j}=gray_img(idx_y(1):idx_y(2),idx_x(1):idx_x(2));
          DISC = abs(idx_x(2)-idx_x(1));
          if DISC > DIS
              DIS = DISC;
              out_img=ObjCell{j};
          end
          %figure; imshow(ObjCell{j});
    end
    %figure; imshow(out_img);
    %imshow(out_img);
end

