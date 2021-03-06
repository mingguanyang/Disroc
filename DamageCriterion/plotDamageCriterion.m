% clear
% D = 0:0.00001:1;

% beta_list = 10.^(-0.5:0.1:0.5);
% beta_angle_list = 10.^(-0.5:0.1:0.5);
% hr_list = 0.6:0.1:0.9;
D=0
beta_list = [0.1]
beta_angle_list = [1];
hr_list = 0.33;

% beta = 0.1;
% beta_angle = 1;
% hr =0.33;
figure(1);hold on;
figure(2);hold on;
figure(3);hold on;
for i = 1:1:length(beta_list)
    for j = 1:1:length(beta_angle_list)
        for k = 1:1:length(hr_list)
            beta = beta_list(i);
            beta_angle = beta_angle_list(j);
            hr = hr_list(k);            
            
%             gD = (1-D).*(1-beta*log(1-D));
            gD = (1-D).^beta;
            hD = hr+(1-D).^beta_angle*(1-hr);
            XD = gD./hD;
            figure(1);plot(D,gD);
            figure(2);plot(D,hD);
            figure(3);plot(D,XD);
            max(XD)
        end
    end
end
%%
D = 0;
for i = 1:1:length(beta_list)
    for j = 1:1:length(beta_angle_list)
        for k = 1:1:length(hr_list)
            beta = beta_list(i);
            beta_angle = beta_angle_list(j);
            hr = hr_list(k);            
            
            gD = (1-D).*(1-beta*log(1-D));
%             gD = (1-D).^beta;
            hD = hr+(1-D).^beta_angle*(1-hr);
            XD = gD./hD;
            c = 2; %MPa
            sigma_R = 1; %MPa
            phi = 30/180*pi; % 
            tau_c = ( c^2+(sigma_R*tan(phi))^2 ) / (2*sigma_R*tan(phi));
            b = ( c^2 - (sigma_R*tan(phi))^2 ) / (2*sigma_R*tan(phi));
            tau_axe = [-1.5:0.01:1.5]*tau_c;
            sigma_axe = [-1.5:0.01:1.5]*tau_c/tan(phi);
            sigma_n = 1/hD/tan(phi)*(gD*tau_c-sqrt(tau_axe.^2+gD^2*b^2));
            tau_asymp_positive = hD*tan(phi)*sigma_axe-gD*tau_c;
            tau_asymp_negative = -hD*tan(phi)*sigma_axe+gD*tau_c;
            sigma_asymp_negative = 1/hD/tan(phi)*(gD*tau_c-tau_axe);
            figure(4);hold on;
            plot(sigma_n,tau_axe)
            plot(sigma_axe,tau_asymp_positive,'--k',...
                sigma_axe,tau_asymp_negative,'--k');
             xlim([-1,1]*tau_c*gD/hD/tan(phi))
        end
    end
end
disp("finished")