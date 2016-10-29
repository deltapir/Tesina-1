clear all
close all
clc

%% CASO MONOSTADIO - R1234yf 
%DATI PROBLEMA
%fluid={'R1234yf' 'R245fa' 'R134a'};
T_B=-12; %°C
%T_A_vett=[35 45 60];  %°C
T_A_vett=[35 45 60];
DT_min_ev=8;
DT_min_co=8;
DT_sur=3;
Qco=10;  %KW
q5=0;
q7=1;

a=-2.648;   
b=1.553;
c=0.6085;

for f=1:3
    if f==1
        fluid='R1234yf'
        title_fluido=sprintf('Fluido R1234yf');
    else
        if f==2
            fluid='R245fa'
            title_fluido=sprintf('Fluido R245fa');

        else
            fluid='R134a'
            title_fluido=sprintf('Fluido R134a');
        end
    end
 
%%CASO MONOSTADIO
for i=1:length(T_A_vett)
    T_A=T_A_vett(i);
    T_1=T_B-DT_min_ev;
    T_ev=T_B-DT_sur-DT_min_ev;
    T_co=T_A+DT_min_co;

    p_ev=refpropm('p','T',T_ev+273.15,'q',1,fluid)/100;
    p_1=p_ev;
    s_1=refpropm('s','T',T_1+273.15,'p',p_1*100,fluid)/1000;
    h_1=refpropm('h','T',T_1+273.15,'p',p_1*100,fluid)/1000;
    
    s2_s=s_1;
    p_co=refpropm('p','T',T_co+273.15,'q',1,fluid)/100;
    p_2s=p_co;
    h_2s=refpropm('h','p',p_2s*100,'s',s2_s*1000,fluid)/1000;
    
    beta_c(i)=p_2s/p_1;
    eta_c=a*exp(-b*beta_c(i))+c;
    h_2=((h_2s-h_1)/eta_c)+h_1;
    p_2=p_2s;
    T_2=refpropm('T','p',p_2s*100,'h',h_2*1000,fluid)-273.15;
    s_2=refpropm('s','p',p_2s*100,'h',h_2*1000,fluid)/1000;
    
    p_3=p_2;
    T_3=refpropm('T','p',p_3*100,'q',0,fluid)-273.15;
    s_3=refpropm('s','p',p_3*100,'q',0,fluid)/1000;
    h_3=refpropm('h','p',p_3*100,'q',0,fluid)/1000;
    
    h_4=h_3;
    p_4=p_1;
    T_4=T_ev;
    s_4=refpropm('s','p',p_4*100,'h',h_4*1000,fluid)/1000;
    q_4=refpropm('q','p',p_3*100,'h',h_4*1000,fluid);

    
 % Poichè cambia T_A e quindi i punti del ciclo, cambierà anche la portata
 % necessaria per assicurare la Qco di progetto (che è fissa)

 m(i)=Qco/(h_2-h_3);
 
%Cambia, per lo stesso motivo, la potenza da fornire al compressore
 L=m(i)*(h_2-h_1);
 
 %Calcolo il COP che sarà sempre variabile con i
 COP(i)=Qco/L;
 T_co(i)=T_co;
end


%%CASO BISTADIO
for i=1:length(T_A_vett);
    
    T_A=T_A_vett(i);
    T1=T_B-DT_min_ev;
    Tev=T_B-DT_sur-DT_min_ev;
    Tco=T_A+DT_min_co;
    
    Tintvett=linspace(Tev,Tco-1,50);
    for j=1:length(Tintvett);
        
        pint(j)=refpropm('p','t',Tintvett(j)+273.15,'q',0,fluid)/100;
  
        %% Calcolo delle proprietà
    
        %punto 1
    pev=refpropm('p','T',Tev+273.15,'q',1,fluid)/100;
    p1=pev;
    s1=refpropm('s','T',T1+273.15,'p',p1*100,fluid)/1000;
    h1=refpropm('h','T',T1+273.15,'p',p1*100,fluid)/1000;
    
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
    h4=refpropm('h','t',T4+273.15,'p',p4*100,fluid)/1000;
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

    %%calcoli sul cop
    
    m4=Qco/(h4-h5);             %portata al punto 4
    m1(j)=m4*h4/(h2+h3*(h8-h5)/(h6-h7));   %portata in 7
    m7(j)=m4-m1(j);  
    %pint(j)=pint
    cop(j)=m4*(h4-h5)/(m1(j)*(h2-h1)+m7(j)*(h3-h7));
    Dcop(j)=(cop(j)-COP(i))/COP(i)*100;              %variazione del cop bistadio rispetto il caso monostadio
    
%     PUNTO 9
%     FISSO LA TEMPERATURA DEL CONDENSATORE (Tco=60°C) e la PRESSIONE DEL
%     COMPRESSORE DI ALTA PRESSIONE ([5.58478329336861]bar) corrispoondente più o meno al COP massimo nel caso bistaadio. L'indice j che
%     corrisponde a questi valori è j=24. Quindi mi prendo i valori per
%     j=24. Entro con questi dati all'interno dell'IF e mi calcolo la cilindrata dei due compressori    
    if (j==24)&&(T_A==60)
        %j=24;
        ac=1.086; %valori per il rendimento del compressore
        bc=-0.07129;
        pintscelta=pint(j)
%     COMPRESSORE ALTA
        betacil(j)=pco/pint(j); %la pint(j) si riferisce al suo ultimo valore nelle T_A_vett. Quindi si riferisce sempre ai 60°C.
        etacil(j)=ac*exp(bc*betacil(j)); %rendimento del compressore volumetrico
        rho=refpropm('d','p',pint(j)*100,'h',h7*1000,fluid); %densità dell'aria aspirata al punto 7
        CILa=m7(j)*1000/(50*rho*etacil(j))  %cilindrata in LITRI
%     COMPRESSORE BASSA
        betacilb=pco/pev;
        etacilb=ac*exp(bc*betacilb); %rendimento del compressore volumetrico
        rho=refpropm('d','p',pev*100,'h',h1*1000,fluid); %densità dell'aria aspirata al punto 1
        CILb=m1(j)*1000/(50*rho*etacilb)   %cilindrata in LITRI - decimetri cubici
    end
    
    
    end %fine ciclo temperatura intermedia j
    
    T_A_vett(i) %per far apparire in output la temperatura
    
    %GRAFICO DELTACOPvsTEMPERATURA INTERNA
    figure(1)
    subplot(1,3,f)
    grid on
    legend_temperatura{i}=sprintf('Temperatura CO %i °C',T_A_vett(i));
    plot(Tintvett, Dcop);
    legend(legend_temperatura);
    hold on
    title(title_fluido);
    xlabel('Temperatura Intermedia [°C]','FontName','Times','FontSize',18,'FontWeight','Bold')
    ylabel('\DeltaCOP [%]','FontName','Times','FontSize',18,'FontWeight','Bold') 
    hold on


    %GRAFICO PORTATA DEL COMPRESSORE DI BASSA PRESSIONE vs PRESSIONE
    %INTERNA
    figure(2)
    subplot(1,3,f)
    grid on
    legend_portata_cpbasso{i}=sprintf('Temperatura CO %i °C',T_A_vett(i));
    plot(pint, m1);
    legend(legend_portata_cpbasso);
    hold on
    title(title_fluido);
    xlabel('Pressione intermedia [bar]','FontName','Times','FontSize',18,'FontWeight','Bold')
    ylabel('Portata del compressore di BP [kg/s]','FontName','Times','FontSize',18,'FontWeight','Bold') 
    hold on
    
    %GRAFICO PORTATA DEL COMPRESSORE DI ALTA PRESSIONE vs PRESSIONE
    %INTERNA
    figure(3)
    subplot(1,3,f)
    grid on
    legend_portata_cpbasso{i}=sprintf('Temperatura CO %i °C',T_A_vett(i));
    plot(pint, m7);
    legend(legend_portata_cpbasso);
    hold on
    title(title_fluido);
    xlabel('Pressione intermedia [bar]','FontName','Times','FontSize',18,'FontWeight','Bold')
    ylabel('Portata del compressore di AP [kg/s]','FontName','Times','FontSize',18,'FontWeight','Bold') 
    hold on
    

end %fine ciclo temperatura di condensazione i


    
    
    %================================================================
    %set(gca,'FontName','Times','FontSize',18,'FontWeight','Bold')
    %title('Diagramma T-s. Caso bistadio-R1234yf','FontName','Times','FontSize',20,'FontWeight','Bold')
    
end %fine cirlo fluido f
figure(1)
suptitle('\DeltaCOP - Temperatura intermedia')

figure(2)
suptitle('Portata BP - Pressione intermedia')

figure(3)
suptitle('Portata AP - Pressione intermedia')