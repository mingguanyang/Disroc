SingleFracture1_step1

Imposed_disp = 5e-1;

%% Resumption
resumption.active      = 1;
resumption.step.active = 1;
resumption.step.number = 1;
saveas_step.number     = 2;
%% write boudary conditions

clear boundary;
boundary.Ux.count = 4;
boundary.Ux.text{1} = ['3 ,' num2str(Imposed_disp) ', 0.0, 0.0'];
boundary.Ux.text{2} = ['4 ,' num2str(Imposed_disp) ', 0.0, 0.0'];
boundary.Ux.text{3} = '7 , 0.0, 0.0, 0.0';
boundary.Ux.text{4} = '8 , 0.0, 0.0, 0.0';

boundary.Uy.count = 2;
boundary.Uy.text{1} = '7 , 0.0, 0.0, 0.0';
boundary.Uy.text{2} = '8 , 0.0, 0.0, 0.0';


writeBoundaryConditions( prob_info,boundary )


%% write calculation parameters


% Parameter file
Parameter.proj_path = prob_info.proj_path;
Parameter.proj_name = prob_info.proj_name;
% Problem type information
Parameter.problem.physics      = 1; %1:Mechanics, 2:Hydraulic, 3:Thermal, 4:HM, 5:TM, 6:THM
Parameter.problem.time         = 1; %1:Time Independent, 2:Transient
Parameter.problem.type         = 1;
Parameter.problem.axesymmetry  = 0;
Parameter.problem.planetype    = 1;
Parameter.problem.generalized  = 0;  %?
Parameter.problem.hyro.matrix  = 1;
Parameter.problem.hydro.gravity.active = 0;
Parameter.problem.hydro.gravity.value  = 0.0098;
Parameter.problem.user         = 1;
% Special parameters

Parameter.specpara.staging     = 0;
Parameter.specpara.stepnum     =  saveas_step.number; % savee all the results in this step
Parameter.specpara.boundaryforce = 0;

% Load parameters

Parameter.load.resumption.active = resumption.active; 
Parameter.load.maxratio          = 1.0;
Parameter.load.volumeforce.active= 0;
Parameter.load.volumeforce.gx    = 0;
Parameter.load.volumeforce.gy    = -0.0981;
Parameter.load.resumption.stepnum = resumption.step.number;    % 91 Step num for resumption
Parameter.load.resumption.stepactive =  resumption.step.active;       % 99

% Calculation parameters
Parameter.calpara.loadincrement         = 1000;
Parameter.calpara.itermax               = 1000;
Parameter.calpara.tolerance.criteria    = 1e-6;
Parameter.calpara.tolerance.convergence = 1e-6;
Parameter.calpara.tolerance.displacement= 1e-4;

Parameter.calpara.time.start            = 0;
Parameter.calpara.time.end              = 1;
Parameter.calpara.time.increment        = 1e-1;


%% write material parameters


% Parameter file
Material.proj_path = prob_info.proj_path;
Material.proj_name = prob_info.proj_name;

Material.total_number = 2;

% LinearElastic

Material.type{1}.name = 'LinearElastic';
Material.type{1}.nature = 30000;
Material.type{1}.mecha.modelnum = 31100;
Material.type{1}.mecha.numPara  = 2;
Material.type{1}.mecha.Para(1)  = 1e10;  % Young's modulus
Material.type{1}.mecha.Para(2)  = 0.25;  % Poisson
Material.type{1}.hydro.modelnum = 0;
Material.type{1}.hydro.numPara  = 0;
Material.type{1}.couplingPar(1) = 0;    % selfweight
Material.type{1}.couplingPar(2) = 0;  % biot's coefficient
Material.type{1}.couplingPar(3) = 0;    % thermoespansion


% Fracture1

Material.type{2}.name = 'Fracture1';
Material.type{2}.nature = 20000;
Material.type{2}.mecha.modelnum  = 21120;
Material.type{2}.mecha.numPara   = 5;
Material.type{2}.mecha.Para(1)   = Kt;      % Kt 
Material.type{2}.mecha.Para(2)   = Kn;      % Kn
Material.type{2}.mecha.Para(3)   = 10;       % Knt
Material.type{2}.mecha.Para(4)   = c;       % c
Material.type{2}.mecha.Para(5)   = phi;       % phi


Material.type{2}.hydro.modelnum = 0;
Material.type{2}.hydro.numPara  = 0;
Material.type{2}.couplingPar(1) = 0;    % selfweight
Material.type{2}.couplingPar(2) = 0;  % biot's coefficient
Material.type{2}.couplingPar(3) = 0;    % thermoespansion

%% run Disroc
runDisroc(Parameter,Material,Disroc_path)
%% save to step 1
foldername = [Parameter.proj_path,'\STEP-',num2str(saveas_step.number)];
if not(exist(foldername,'dir'))
        mkdir(foldername)
end
cmd_txt = ['copy', ' ', Parameter.proj_path,'\RepM.dat', ' ',...
     foldername,'\RepM.dat'];
system(cmd_txt)
cmd_txt = ['copy', ' ', Parameter.proj_path,'\',...
     erase(Parameter.proj_name,'gid'), '*', ' ',...
     foldername,'\',erase(Parameter.proj_name,'gid'), '*'];
 system(cmd_txt)
 
 %% Plot

TimeIncrement = 1;
TimeEndRatio = 1;
plotJointElemNo = 5;
%
fnameJointMecha = strcat(Material.proj_path,'\','201.jointMecha.dat');
fidJointMecha   = fopen(fnameJointMecha,'r');
cellJoinMecha   = textscan(fidJointMecha, '%f %d %f %f %f %f %f %f %f','Headerlines',1);
TimeEnd = floor(length(cellJoinMecha{1})/TimeEndRatio);
Time    = cellJoinMecha{1}(1:TimeIncrement:TimeEnd)*Imposed_disp;
NoElem  = cellJoinMecha{2}(1:TimeIncrement:TimeEnd);
Ut      = cellJoinMecha{3}(1:TimeIncrement:TimeEnd);
Un      = cellJoinMecha{4}(1:TimeIncrement:TimeEnd);
Tau     = cellJoinMecha{5}(1:TimeIncrement:TimeEnd);
Sn      = cellJoinMecha{6}(1:TimeIncrement:TimeEnd);
Utp     = cellJoinMecha{7}(1:TimeIncrement:TimeEnd);
Unp     = cellJoinMecha{8}(1:TimeIncrement:TimeEnd);
Damage  = cellJoinMecha{9}(1:TimeIncrement:TimeEnd);
fclose(fidJointMecha);


% Time evolution plot
isPlot = NoElem==plotJointElemNo;
f1 = figure(1); 
clf;
hold on;
plot(Time(isPlot), Tau(isPlot)/1e6,'r')
% plot asymptotic line
% plot([Time(1),Time(end)], Tau(end)*[1,1]/1e6)
plot(Time(isPlot), Sn(isPlot)/1e6,'b')
% % plot(Time(isPlot), Tau(isPlot)./Sn(isPlot),'-k')
% plot(Time(isPlot), Utp(isPlot)/Utp(end))
% plot(Time(isPlot), Damage(isPlot))

xlabel('Shear displacement [/m]','interpreter','latex')
ylabel('Stress [/MPa]','interpreter','latex')
title('Fault with Mohr-Coulomb Failure criteria','interpreter','latex')
legtex{1} = '$\tau$';
legtex{2} = '$\sigma_n$';
legend(legtex,'interpreter','latex','Location','best');
grid on;
box on;
saveas(f1,'.\Projects\Faultbehaviour\SingleFracture1\Mohr-Colomb.pdf')