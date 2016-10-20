clear all
close all
clc

%% CASO BISTADIO - R1234yf 
%DATI PROBLEMA
fluid='R1234yf';
T_B=-12; %�C
T_A_vett=[35 45 60];  %�C
DT_min_ev=8;
DT_min_co=8;
DT_sur=3;
Qco=10;  %KW
q5=0;
q7=1;
% T8=T6

a=-2.648;   
b=1.553;
l=0.6085;



for i=1:length(T_A_vett)
    T_A=T_A_vett(i);
    
    %% Calcolo delle propriet�
    
    %punto 1
    T1=T_B-DT_min_ev;
    Tev=T_B-DT_sur-DT_min_ev;
    pev=refpropm('p','T',Tev+273.15,'q',1,fluid)/100;
    p1=pev;
    s1=refpropm('s','T',T1+273.15,'p',p1*100,fluid)/1000;
    h1=refpropm('h','T',T1+273.15,'p',p1*100,fluid)/1000;
    
    %punti 2s e 2
    s2s=s1;
    Tco=T_A+DT_min_co;
    pco=refpropm('p','T',Tco+273.15,'q',1,fluid)/100;
    p2s=pco;
    T2s=refpropm('T','p',pco*100,'s',s2s*1000,fluid)-273.15;
    h2s=refpropm('h','p',p2s*100,'s',s2s*1000,fluid)/1000;
    
    beta_c=p2s/p1;
    eta_c=a*exp(-b*beta_c)+l;
    h2=((h2s-h1)/eta_c)+h1;
    p2=p2s;
    T2=refpropm('T','p',p2s*100,'h',h2*1000,fluid)-273.15;
    s2=refpropm('s','p',p2s*100,'h',h2*1000,fluid)/1000;
    
    %fisso pint
    pint=refpropm('p','t',Tev+Tco+273.15,'q',0,fluid)/100;
    
    %punto 7
    p7=pint;
    T7=refpropm('t','p',pint*100,'q',q7,fluid)-273.15;
    h7=refpropm('h','t',T7+273.15,'q',q7,fluid)/1000;
    s7=refpropm('s','t',T7+273.15,'q',q7,fluid)/1000;
    
    %punti 3s e 3
    s3s=s7;
    p3s=pco;
    h3s=refpropm('h','p',p3s*100,'s',s3s*1000,fluid)/1000;
    T3s=refpropm('T','p',p3s*100,'h',h3s*1000,fluid)-273.15;
    
    beta_c=p3s/p7;
    eta_c=a*exp(-b*beta_c)+l;
    h3=((h3s-h7)/eta_c)+h7;
    p3=p3s;
    T3=refpropm('T','p',p3s*100,'h',h3*1000,fluid)-273.15;
    s3=refpropm('s','p',p3s*100,'h',h3*1000,fluid)/1000;
    
    %punto 4
    T4=(T2+T3)/2;
    p4=p3;
    h4=refpropm('h','t',T4+273.15,'p',p4*100,fluid)/1000;
    s4=refpropm('s','t',T4+273.15,'p',p4*100,fluid)/1000;
    
    %punto 5
    p5=p2;
    T5=refpropm('t','p',p5*100,'q',q5,fluid)-273.15;
    s5=refpropm('s','t',T5+273.15,'q',q5,fluid)/1000;
    h5=refpropm('h','t',T5+273.15,'q',q5,fluid)/1000;
    
    %punto 6
    h6=h5;
    p6=pint;
    T6=refpropm('t','p',p6*100,'h',h6*1000,fluid)-273.15;
    s6=refpropm('s','p',p6*100,'h',h6*1000,fluid)/1000;
    
    %punto 8
    T8=T6;
    p8=p2;
    h8=refpropm('h','t',T8+273.15,'p',p8*100,fluid)/1000;
    s8=refpropm('s','t',T8+273.15,'p',p8*100,fluid)/1000;
    
    %punto 9
    h9=h8;
    p9=p1;
    T9=refpropm('t','p',p9*100,'h',h9*1000,fluid)-273.15;
    s9=refpropm('s','p',p9*100,'h',h9*1000,fluid)/1000;


%% GRAFICO PIANO T-s
% Individuazione T critica e T minima
Tcr=refpropm('T','C',0,' ',0,fluid)-273.15;
Tmin=T1-10;
%Creo un vettore di T che vanno da quella minima a quella critica
T_vett=Tmin:0.5:Tcr;
%Creo i vettori di entropia per il liquido e il vapore
for j=1:length(T_vett)-1;
    s_L(j)=refpropm('s','T',T_vett(j)+273.15,'q',0,fluid)/1000;
    s_V(j)=refpropm('s','T',T_vett(j)+273.15,'q',1,fluid)/1000;
end
%Per chiudere la campana trovo la s del punto critico
scr=refpropm('s','C',0,' ',0,fluid)/1000;
s_L(length(T_vett))=scr;
s_V(length(T_vett))=scr;

% 1-2
t_vett1=linspace(T1,T2,2);
s_vett1=linspace(s1,s2,2);

% 7-3
t_vett2=linspace(T7,T3,2);
s_vett2=linspace(s7,s3,2);

% isobara 8-2, la spezzo in 3 parti

t_vett3=linspace(T8,T5,80);
for k=1:length(t_vett3)-1
    s_vett3(k)=refpropm('s','T',t_vett3(k)+273.15,'p',p2*100,fluid)/1000;
end
s_vett3(length(t_vett3))=s5;

%creo un punto fittizio a p=p2 e q=1
qf=1;
pf=p2;
Tf=refpropm('T','p',pf*100,'q',qf,fluid)-273.15;
sf=refpropm('s','p',pf*100,'q',qf,fluid)/1000;
t_vett4=linspace(T5,Tf,80);
s_vett4=linspace(s5,sf,80);

t_vett5=linspace(T2,Tf,30);
for z=1:length(t_vett5)-1
    s_vett5(z)=refpropm('s','T',t_vett5(z)+273.15,'p',p2*100,fluid)/1000;
end
s_vett5(length(t_vett5))=sf;

% isobara 6-7
t_vett6=linspace(T6,T7,2);
s_vett6=linspace(s6,s7,2);

% isoentalpica 5-6
t_vett7=linspace(T5,T6,80);
for a=1:length(t_vett7)-1
    s_vett7(a)=refpropm('s','T',t_vett7(a)+273.15,'h',h5*1000,fluid)/1000;
end
s_vett7(length(t_vett7))=s6;

% isoentalpica 8-9
t_vett8=linspace(T8,T9,80);
for b=1:length(t_vett8)-1
    s_vett8(b)=refpropm('s','T',t_vett8(b)+273.15,'h',h8*1000,fluid)/1000;
end
s_vett8(length(t_vett7))=s9;

% isobara 9-1, devo spezzarla in due
% creo un punto fittizio
q_f=1;
p_f=p9;
T_f=refpropm('T','p',p_f*100,'q',q_f,fluid)-273.15;
s_f=refpropm('s','p',p_f*100,'q',q_f,fluid)/1000;

t_vett9=linspace(T9,T_f,2);
s_vett9=linspace(s9,s_f,2);

% Scritto come segue, il pezzo che va dal punto fittizio ad 1 mi fa
% sballare tutto il grafico e non so perch� (tranne la figure 3). Ho
% pertanto unito solo il punto fittizio al punto 1 in maniera rettilinea.
%t_vett_1=linspace(T1,T_f,30);
%for l=1:length(t_vett_1)-1
%    s_vett_1(l)=refpropm('s','T',t_vett_1(l)+273.15,'p',p1*100,fluid)/1000;
%end
%s_vett_1(length(t_vett_1))=s_f;

t_vett_1=linspace(T_f,T1,2);
s_vett_1=linspace(s_f,s1,2);

figure (i)
 plot(s_L,T_vett,'k','linewidth',0.7)
 hold on
 plot(s_V,T_vett,'k','linewidth',0.7)
 hold on
 plot(s_vett1,t_vett1,'--b','linewidth',1)
 hold on
 plot(s_vett2,t_vett2,'--b','linewidth',1)
 hold on
 plot(s_vett3,t_vett3,'b','linewidth',1)
 hold on
 plot(s_vett4,t_vett4,'b','linewidth',1)
 hold on
 plot(s_vett5,t_vett5,'b','linewidth',1)
 hold on
 plot(s_vett6,t_vett6,'b','linewidth',1)
 hold on
 plot(s_vett7,t_vett7,'--b','linewidth',1)
 hold on
 plot(s_vett8,t_vett8,'--b','linewidth',1)
 hold on
 plot(s_vett9,t_vett9,'b','linewidth',1)
 hold on
 plot(s_vett_1,t_vett_1,'b','linewidth',1)
 
 xlabel('Entropia Specifica [kJ/kg K]','FontName','Times','FontSize',18,'FontWeight','Bold')
 ylabel('Temperatura [�C]','FontName','Times','FontSize',18,'FontWeight','Bold') 
 set(gca,'FontName','Times','FontSize',18,'FontWeight','Bold')
 title('Diagramma T-s. Caso bistadio-R1234yf','FontName','Times','FontSize',20,'FontWeight','Bold')
 
 plot([s1 s2 s3 s4 s5 s6 s7 s8 s9],[T1 T2 T3 T4 T5 T6 T7 T8 T9],'ko','MarkerFaceColor','k','MarkerSize',4)
 %plot([s2s s3s],[T2s T3s],'ro','MarkerFaceColor','k','MarkerSize',4) %ma i
 %punti escono quasi sovrapposti l'un l'altro..inutile forse plottarli e
 %disegnare le isoentropiche
end