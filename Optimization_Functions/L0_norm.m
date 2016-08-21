function [N]=L0_norm(x)
%     modified_x=x;
%     modified_x(modified_x < .001)=0;
%     c=.00001;
%     N=round(sum(modified_x.^c)-c);
N=sum(abs(x));
% norm_current=1;
% norm_prev=0;
% N=1;
% diff=1;
% while N > 1/32
%     norm_prev=norm_current;
%     norm_current=(sum(abs(x).^N)).^(1/N)
%     diff=norm_prev-norm_current;
%     N=N/2;
% end




end