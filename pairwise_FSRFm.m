function Iout = pairwise_FSRFm(I,I_rgb,mask,Paramsptr) 
    
    
    %RADARSAT-1 SCAN-SAR NARROW
    %     double L = 4; 
    
    %RADARSAT-1 SCAN-SAR WIDE
    L = 21; 
    % ?
    maxP = 3.3516;
    
    %gets image dimensions
    dims = size(I);
    dimy = dims(1);
    dimx = dims(2);
    
    Ns = Paramsptr(1);
    Nr = Paramsptr(2);
    sig = Paramsptr(3);
    sPercentage = Paramsptr(4);
    Th = Paramsptr(5);
    distance_kernel_sigma = Paramsptr(6); 

    Iout = zeros(dimy, dimx);
    tgamma2L_1 = tgamma(2*L-1);
    tgammaL = tgamma(L);
    C = sqrt(2*pi);
    C2 = 4*L* tgamma2L_1  / power(tgammaL,2)/ maxP;
    
    distance_kernel = fspecial('gaussian',Ns,sqrt(2)*distance_kernel_sigma);
    distance_kernel = C*distance_kernel/max(distance_kernel(:));
    %iterate the input image*/
    % int offset = Ns*Ns;
    search_r = floor(Ns/2);
    patch_r = floor(Nr/2);
    nsb2 = floor(Ns/2)+1+floor(Nr/2)+1; %the patch location bundary buffer size
    for i=nsb2+1:dimy-nsb2
        for j=nsb2+1:dimx-nsb2
            if mask(i,j)
                continue
            end
            pad = floor(Ns/2)+1+floor(Nr/2)+1;
            if i ~= 52+pad*2 && j ~= 296+pad*2
                disp('test');
                continue
            end

        % for each pixel in the domain
          bProcess = randi([1,100],Ns) < distance_kernel*sPercentage;
          bProcess = bProcess & (mask(i-search_r:i+search_r,j-search_r:j+search_r) == 0);
          bProcess(search_r+1,search_r+1) = 0;
          current_patch = I_rgb(i-patch_r:i+patch_r, ...
                            j-patch_r:j+patch_r);
          NI = I(i-search_r:i+search_r,j-search_r:j+search_r);
          NI = NI(bProcess);
          b2 = current_patch.^0.5;
          [sample_row,sample_col] = find(bProcess==1);
          pij = zeros(size(sample_row,1),1);
          for ii = 1:size(sample_row,1)
            sample_loc = [sample_row(ii)-search_r+i-1,sample_col(ii)-search_r+j-1];
            sample_patch = I_rgb(sample_loc(1)-patch_r:sample_loc(1)+patch_r, ...
                            sample_loc(2)-patch_r:sample_loc(2)+patch_r);
           
            b1 = sample_patch.^0.5;
            p = C2 * (b1.*b2./(b1.^2+b2.^2)).^(2*L-1);
            pij(ii) = prod(p(:))^(1.0/double(sig));
          end
          %a = zeros(Ns);
          %figure;
          %for ii = 1:numel(NI)
          %  a(sample_row(ii),sample_col(ii))=pij(ii);
          %end
          %imagesc(a)
          %colormap gray
          %figure
          %imagesc(I_rgb(i-search_r:i+search_r,j-search_r:j+search_r))
          
 
          bU = randi([1,100],numel(pij),1);
          pij(pij*100<bU) = 0;
          IWS = sum(pij.*NI)/sum(pij);
            
          Iout(i,j) =IWS;
        end
    end
end

function r = tgamma(L)
    if  L < 1  
        r=0;
    end    
    r = 1;
    for  i = 2:L-1
        r = r * i;
    end
end