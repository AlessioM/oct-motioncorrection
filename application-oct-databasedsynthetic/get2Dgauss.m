function [ F ] = get2Dgauss( Y, X, mu, sigmas, correlation )

    R = [     1      correlation; 
         correlation      1     ];
     
    D = [ sigmas(1)     0; 
              0     sigmas(2)];
          
    S = D*R*D;

    [Ym,Xm] = meshgrid(Y,X);
    
    F = mvnpdf([Ym(:) Xm(:)],mu,S);
    
    F = reshape(F,length(X),length(Y))';

end

