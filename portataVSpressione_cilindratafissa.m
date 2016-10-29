clear all
close all
clc

%% CASO MONOSTADIO - R1234yf 
%DATI PROBLEMA
%fluid={'R1234yf' 'R245fa' 'R134a'};
T_B=-12; %°C
%T_A_vett=[35 45 60];  %°C
T_A=60;
DT_min_ev=8;
DT_min_co=8;
DT_sur=3;
Qco=10;  %KW
q5=0;
q7=1;

a=-2.648;   
b=1.553;
c=0.6085;
CIL={[0.0295 0.2896] [0.0706 7.5366] [0.0212 0.3744]}; %r1234yf r245fa r134a | cilindrata alta, cilindrata bassa
%anche se dovremmo fissare un fluido. Quindi alla fine abbiamo un solo
%valore di cilindrata.
%fisso il R1234yf

fluid='R1234yf';

%fisso la temperatura a 60°C
%fisso la cilindrata

CILb=0.2896/1000;

%%CASO BISTADIO

    T1=T_B-DT_min_ev;
    Tev=T_B-DT_sur-DT_min_ev;
    Tco=T_A+DT_min_co;
    
    Tintvett=linspace(Tev,Tco-1,100);
    for j=1:length(Tintvett);
        
        pint(j)=refpropm('p','t',Tintvett(j)+273.15,'q',0,fluid)/100;
  
        %% Calcolo delle proprietà
    
        %punto 1
    pev=refpropm('p','T',Tev+273.15,'q',1,fluid)/100;
    p1=pev;
    s1=refpropm('s','T',T1+273.15,'p',p1*100,fluid)/1000;
    h1=refpropm('h','T',T1+273.15,'p',p1*100,fluid)/1000;
    rho1=refpropm('d','p',p1*100,'h',h1*1000,fluid); %densità dell'aria aspirata al punto 1
    
    %punti 2s e 2
    s2s=s1;
    pco=refpropm('p','T',Tco+273.15,'q',1,fluid)/100;
    p2s=pco;
    T2s=refpropm('T','p',p2s*100,'s',s2s*1000,fluid)-273.15;
    h2s=refpropm('h','p',p2s*100,'s',s2s*1000,fluid)/1000;
    
    beta_c1=p2s/p1;
    eta_c1=a*10^(-b*beta_c1)+c;
    h2=((h2s-h1)/eta_c1)+h1;
    p2=p2s;
    T2=refpropm('T','p',p2s*100,'h',h2*1000,fluid)-273.15;
    s2=refpropm('s','p',p2s*100,'h',h2*1000,fluid)/1000;
        
    %punto 7
    p7=pint(j);
    T7=refpropm('t','p',pint(j)*100,'q',q7,fluid)-273.15;
    h7=refpropm('h','t',T7+273.15,'q',q7,fluid)/1000;
    s7=refpropm('s','t',T7+273.15,'q',q7,fluid)/1000;
    
    %punti 3s e 3
    s3s=s7;
    p3s=pco;
    h3s=refpropm('h','p',p3s*100,'s',s3s*1000,fluid)/1000;
    T3s=refpropm('T','p',p3s*100,'h',h3s*1000,fluid)-273.15;
    
    beta_c2=p3s/p7;
    eta_c2=a*exp(-b*beta_c2)+c;
    h3=((h3s-h7)/eta_c2)+h7;
    p3=p3s;
    T3=refpropm('T','p',p3s*100,'h',h3*1000,fluid)-273.15;
    s3=refpropm('s','p',p3s*100,'h',h3*1000,fluid)/1000;
    
    %punto 4
    T4=(T2+T3)/2;
    p4=p3;
    h4(j)=refpropm('h','t',T4+273.15,'p',p4*100,fluid)/1000;
    s4=refpropm('s','t',T4+273.15,'p',p4*100,fluid)/1000;
    
    %punto 5
    p5=p2;
    T5=refpropm('t','p',p5*100,'q',q5,fluid)-273.15;
    s5=refpropm('s','t',T5+273.15,'q',q5,fluid)/1000;
    h5=refpropm('h','t',T5+273.15,'q',q5,fluid)/1000;
    
    %punto 6
    h6=h5;
    p6=pint(j);
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

   %% calcoli
    
    m4(j)=Qco/(h4(j)-h5);               %portata al punto 4
    ac=1.086;                           %valori per il rendimento del compressore
    bc=-0.07129;                        
    betacil=p2/p1;                                  %rapporto di compressione del compressore di bassa pressione
    etacil=ac*exp(bc*betacil);                      %rendimento del compressore di bassa pressione
    m1c(j)=rho1*CILb*50*etacil;                     %portata in 7 con cilindrata fissa
    m1v(j)=m4(j)*h4(j)/(h2+h3*(h8-h5)/(h6-h7));     %portata in 7 con cilindrata variabile
    
    m41c(j)=m1c(j)/m4(j);                           %portata ridotta con cilindrata fissa
    m41v(j)=m1v(j)/m4(j);                           %portata ridotta con cilindrata variabile

    end %fine ciclo temperatura intermedia j

    %% GRAFICO PORTATA DEL COMPRESSORE DI BASSA PRESSIONE vs PRESSIONE
    %  INTERNA
    [x,y]=polyxpoly(pint, m41v,pint,m41c);  %restituisce i due punti dell'intersezione delle due curve
    xi=linspace(0,x,2);
    xi0=[x x];
    yi0=[y y];
    yi=linspace(0,y,2);
    figure(1)
    plot(pint, m41v,'r')
    hold on
    plot(pint,m41c,'k')
    hold on
    plot(x,y,'o',xi0,yi,'--g',xi,yi0,'--g');
    legend('Cilindrata variabile','Cilindrata fissa');
    title('T=60°C; Fluido: r1234yf');
    xlabel('Pressione intermedia [bar]','FontName','Times','FontSize',18,'FontWeight','Bold')
    ylabel('Portata ridotta','FontName','Times','FontSize',18,'FontWeight','Bold')
    grid minor
    
  
