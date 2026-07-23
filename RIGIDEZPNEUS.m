clc
clear
close all

%% Comparação entre diferentes velocidades de avanço
M = readmatrix('Pneu1 0.1mm_s 35psi.txt', 'FileEncoding', 'ISO-8859-1');

d_35_01 = M(:,2);
f_35_01 = M(:,3);

M = readmatrix('Pneu1 0.25mm_s 35psi.txt', 'FileEncoding', 'ISO-8859-1');

d_35_025 = M(:,2);
f_35_025 = M(:,3);


M = readmatrix('Pneu1 0.5mm_s 35psi.txt', 'FileEncoding', 'ISO-8859-1');

d_35_05 = M(:,2);
f_35_05 = M(:,3);

M = readmatrix('Pneu1 1mm_s 35psi 2.txt', 'FileEncoding', 'ISO-8859-1');

d_35_1 = M(:,2);
f_35_1 = M(:,3);

figure (1)
plot(d_35_01, f_35_01, 'b', 'LineWidth', 2);
xlabel('Deformação [mm]');
ylabel('Força [N]');
grid on;
hold on
plot(d_35_025, f_35_025, 'r', 'LineWidth', 2);
plot(d_35_05, f_35_05, 'g', 'LineWidth', 2);
plot(d_35_1, f_35_1, 'm', 'LineWidth', 2);
legend('0.1 mm/s', '0.25 mm/s', '0.5 mm/s', '1.0 mm/s', ...
       'Location','NW');
xlim([0 18]);
set(gca,'FontName','Times','FontWeight','bold','FontSize',10)
exportgraphics(gcf, 'Velocidades.pdf', 'ContentType', 'vector');


   
%% Pressões pneu De direção

M = readmatrix('Pneu1 0.5mm_s 7psi.txt', 'FileEncoding', 'ISO-8859-1');
d_7_p1 = M(:,2);
f_7_p1 = M(:,3);

M = readmatrix('Pneu1 0.5mm_s 14psi.txt', 'FileEncoding', 'ISO-8859-1');
d_14_p1 = M(:,2);
f_14_p1 = M(:,3);

M = readmatrix('Pneu1 0.5mm_s 21psi.txt', 'FileEncoding', 'ISO-8859-1');
d_21_p1 = M(:,2);
f_21_p1 = M(:,3);

M = readmatrix('Pneu1 0.5mm_s 28psi.txt', 'FileEncoding', 'ISO-8859-1');
d_28_p1 = M(:,2);
f_28_p1 = M(:,3);

% Valores finais de rigidez
Rig1_7 = f_7_p1(end)/d_7_p1(end);
Rig1_14 = f_14_p1(end)/d_14_p1(end);
Rig1_21 = f_21_p1(end)/d_21_p1(end);
Rig1_28 = f_28_p1(end)/d_28_p1(end);
Rig1_35 = f_35_05(end)/d_35_05(end);

rig_p1 = [Rig1_7, Rig1_14, Rig1_21, Rig1_28, Rig1_35];

figure (2)
plot(d_7_p1, f_7_p1, 'b', 'LineWidth', 2);
xlabel('Deformação [mm]');
ylabel('Força [N]');
title('Pneu de direção');
grid on;
hold on
plot(d_14_p1, f_14_p1, 'r', 'LineWidth', 2);
plot(d_21_p1, f_21_p1, 'g', 'LineWidth', 2);
plot(d_28_p1, f_28_p1, 'm', 'LineWidth', 2);
plot(d_35_05, f_35_05, 'k', 'LineWidth', 2);

legend( sprintf('7 [psi] - k = %.2f [N/mm]', Rig1_7),sprintf('14 [psi] - k = %.2f [N/mm]', Rig1_14),...
   sprintf('21 [psi] - k = %.2f [N/mm]', Rig1_21), sprintf('28 [psi] - k = %.2f [N/mm]', Rig1_28),...
   sprintf('35 [psi] - k = %.2f [N/mm]', Rig1_35), 'location', 'NW');
xlim([0 18]);
set(gca,'FontName','Times','FontWeight','bold','FontSize',10)

exportgraphics(gcf, 'pneudirecao.pdf', 'ContentType', 'vector');
 %% Pressões pneus de tração;
   
M = readmatrix('pneu2 05mm_s 7psi.txt', 'FileEncoding', 'ISO-8859-1');
d_7_p2 = M(:,2);
f_7_p2 = M(:,3);

M = readmatrix('pneu2 05mm_s 14psi.txt', 'FileEncoding', 'ISO-8859-1');
d_14_p2 = M(:,2);
f_14_p2 = M(:,3);

M = readmatrix('pneu2 05mm_s 21psi.txt', 'FileEncoding', 'ISO-8859-1');
d_21_p2 = M(:,2);
f_21_p2 = M(:,3);

M = readmatrix('pneu2 05mm_s 28psi.txt', 'FileEncoding', 'ISO-8859-1');
d_28_p2 = M(:,2);
f_28_p2 = M(:,3);

M = readmatrix('pneu2 05mm_s 35psi.txt', 'FileEncoding', 'ISO-8859-1');
d_35_p2 = M(:,2);
f_35_p2 = M(:,3);

% Valores finais de rigidez
Rig2_7 = f_7_p2(end)/d_7_p2(end);
Rig2_14 = f_14_p2(end)/d_14_p2(end);
Rig2_21 = f_21_p2(end)/d_21_p2(end);
Rig2_28 = f_28_p2(end)/d_28_p2(end);
Rig2_35 = f_35_p2(end)/d_35_p2(end);

rig_p2 = [Rig2_7, Rig2_14, Rig2_21, Rig2_28, Rig2_35];


figure (3)
plot(d_7_p2, f_7_p2, 'b', 'LineWidth', 2);
xlabel('Deformação [mm]');
ylabel('Força [N]');
title('Pneu de tração');
grid on;
hold on
plot(d_14_p2, f_14_p2, 'r', 'LineWidth', 2);
plot(d_21_p2, f_21_p2, 'g', 'LineWidth', 2);
plot(d_28_p2, f_28_p2, 'm', 'LineWidth', 2);
plot(d_35_p2, f_35_p2, 'k', 'LineWidth', 2);
legend( sprintf('7 [psi] - k = %.2f [N/mm]', Rig2_7),sprintf('14 [psi] - k = %.2f [N/mm]', Rig2_14),...
   sprintf('21 [psi] - k = %.2f [N/mm]', Rig2_21), sprintf('28 [psi] - k = %.2f [N/mm]', Rig2_28),...
   sprintf('35 [psi] - k = %.2f [N/mm]', Rig2_35), 'location', 'NW');
xlim([0 18]);
set(gca,'FontName','Times','FontWeight','bold','FontSize',10)
exportgraphics(gcf, 'pneutracao.pdf', 'ContentType', 'vector');
%% plot dos gráficos juntos

figure(4)
subplot(2,1,1)
plot(d_7_p1, f_7_p1, 'b', 'LineWidth', 2);
ylabel('Força [N]');
xlabel('Deformação [mm]');
ylim([0 2500]);
title('Pneu de direção');
grid on;
hold on
plot(d_14_p1, f_14_p1, 'r', 'LineWidth', 2);
plot(d_21_p1, f_21_p1, 'g', 'LineWidth', 2);
plot(d_28_p1, f_28_p1, 'm', 'LineWidth', 2);
plot(d_35_05, f_35_05, 'k', 'LineWidth', 2);
 
legend ('7 [psi]', '14 [psi]','21 [psi]', '28 [psi]', '35 [psi]', 'location', 'NW')
xlim([0 18]);
set(gca,'FontName','Times','FontWeight','bold','FontSize',10)


subplot(2,1,2)
plot(d_7_p2, f_7_p2, 'b', 'LineWidth', 2);
ylabel('Força [N]');
ylim([0 3000]);
xlabel('Deformação [mm]');
title('Pneu de tração');
grid on;
hold on
plot(d_14_p2, f_14_p2, 'r', 'LineWidth', 2);
plot(d_21_p2, f_21_p2, 'g', 'LineWidth', 2);
plot(d_28_p2, f_28_p2, 'm', 'LineWidth', 2);
plot(d_35_p2, f_35_p2, 'k', 'LineWidth', 2);

xlim([0 18]);
set(gca,'FontName','Times','FontWeight','bold','FontSize',10)

exportgraphics(gcf, 'pneus.pdf', 'ContentType', 'vector');




%% grafico de rigidez 

pressao = [7,14,21,28,35];

figure (5)
plot(pressao, rig_p1, '-o', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('Pressão dos pneus [psi]');
ylabel('Rigidez equivalente [N/mm]');
xticks(0:7:35)
xlim([5 37])
grid on;
hold on;
plot(pressao, rig_p2,'-or','LineWidth', 2, 'MarkerSize', 8);
legend('Pneu de direção', 'Pneu de tração', 'location', 'NW')
set(gca,'FontName','Times','FontWeight','bold','FontSize',10)
exportgraphics(gcf, 'rigidez.pdf', 'ContentType', 'vector');


%Dados de amortecimento 

B_tf = [9,146640743,
       6,66037207,
       6,020767339,
       5,290942593,
       4,694518383];

B_tr = [8,957942896,
    7,445931086,
    6,56739394,
    5,475255047,
    5,698219714];


% Rigidez dos pneus: direção (traseiro) e tração (dianteiro)
rig_p1 = [Rig1_7, Rig1_14, Rig1_21, Rig1_28, Rig1_35];   % [N/mm] – traseiro
rig_p2 = [Rig2_7, Rig2_14, Rig2_21, Rig2_28, Rig2_35];   % [N/mm] – dianteiro

% Dados experimentais
pressao = [7 14 21 28 35]; % [psi]

amort_p1 = [34.62482948, 33.94912285, 32.61179326, 30.56064406, 27.5192764]; % [N.s/m]
amort_p2 = [40.99092234, 38.35331187, 36.91272917, 35.26975838, 34.19564178]; % [N.s/m]

% Gráfico
figure (6)
plot(pressao, amort_p1, '-ob', 'LineWidth', 1.5, 'MarkerSize', 6)
hold on
plot(pressao, amort_p2, '-or', 'LineWidth', 1.5, 'MarkerSize', 6)

grid on
xlabel('Pressão dos pneus [psi]')
ylabel('Amortecimento equivalente [N.s/m]')
legend('Pneu de direção', 'Pneu de tração', 'Location', 'best')
xlim([5 37])
xticks(pressao)
set(gca,'FontName','Times','FontWeight','bold','FontSize',10)
exportgraphics(gcf, 'amortecimento.pdf', 'ContentType', 'vector');
    

    
