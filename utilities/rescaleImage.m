function imageOut = rescaleImage(image,scale)
%rescales an image

    s = size(image);
    s2 = round(s*scale);
    
    if min(s == s2) == 1
        
        imageOut = image;
        
    else 
       
        if scale > 1
        
            startIdx = floor((s2 - s)/2);
            imageOut = imresize(image,s2);
            imageOut = imageOut((1:s(1))+startIdx(1),(1:s(2))+startIdx(2));
                   
        else
        
            startIdx = floor((s - s2)/2);
            image2 = imresize(image,s2);
            imageOut = uint8(zeros(s));
            imageOut((1:s2(1)) + startIdx(1),(1:s2(2)) + startIdx(2)) = image2;
            
        end
            
            
    end