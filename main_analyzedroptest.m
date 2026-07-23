clear;clc;close all;

fs = 3200;
fc = 100;

data = importdata('test_35psi.lvm','\t',24);
data = data.data(:,2:4);

a_cg = data(:,1);
a_rear = data(:,2);
a_front = data(:,3);
t = (0:(length(a_cg)-1))/fs;

figure;
subplot(3,1,1);
plot(t,a_cg,'b');xlim([0 3]);ylim([-20 20]);
title('35 psi');
xlabel('Time [sec]');
ylabel('a_{cg} [g]');
subplot(3,1,2);
plot(t,a_rear,'r');xlim([0 3]);ylim([-20 20]);
xlabel('Time [sec]');
ylabel('a_{rear} [g]');
subplot(3,1,3);
plot(t,a_front,'k');xlim([0 3]);ylim([-20 20]);
xlabel('Time [sec]');
ylabel('a_{front} [g]');

data = importdata('test_28psi.lvm','\t',24);
data = data.data(:,2:4);

a_cg = data(:,1);
a_rear = data(:,2);
a_front = data(:,3);
t = (0:(length(a_cg)-1))/fs;

figure;
subplot(3,1,1);
plot(t,a_cg,'b');xlim([0 3]);ylim([-20 20]);
title('28 psi');
xlabel('Time [sec]');
ylabel('a_{cg} [g]');
subplot(3,1,2);
plot(t,a_rear,'r');xlim([0 3]);ylim([-20 20]);
xlabel('Time [sec]');
ylabel('a_{rear} [g]');
subplot(3,1,3);
plot(t,a_front,'k');xlim([0 3]);ylim([-20 20]);
xlabel('Time [sec]');
ylabel('a_{front} [g]');

data = importdata('test_21psi.lvm','\t',24);
data = data.data(:,2:4);

a_cg = data(:,1);
a_rear = data(:,2);
a_front = data(:,3);
t = (0:(length(a_cg)-1))/fs;

figure;
subplot(3,1,1);
plot(t,a_cg,'b');xlim([0 3]);ylim([-20 20]);
title('21 psi');
xlabel('Time [sec]');
ylabel('a_{cg} [g]');
subplot(3,1,2);
plot(t,a_rear,'r');xlim([0 3]);ylim([-20 20]);
xlabel('Time [sec]');
ylabel('a_{rear} [g]');
subplot(3,1,3);
plot(t,a_front,'k');xlim([0 3]);ylim([-20 20]);
xlabel('Time [sec]');
ylabel('a_{front} [g]');

data = importdata('test_14psi.lvm','\t',24);
data = data.data(:,2:4);

a_cg = data(:,1);
a_rear = data(:,2);
a_front = data(:,3);
t = (0:(length(a_cg)-1))/fs;

figure;
subplot(3,1,1);
plot(t,a_cg,'b');xlim([0 3]);ylim([-20 20]);
title('14 psi');
xlabel('Time [sec]');
ylabel('a_{cg} [g]');
subplot(3,1,2);
plot(t,a_rear,'r');xlim([0 3]);ylim([-20 20]);
xlabel('Time [sec]');
ylabel('a_{rear} [g]');
subplot(3,1,3);
plot(t,a_front,'k');xlim([0 3]);ylim([-20 20]);
xlabel('Time [sec]');
ylabel('a_{front} [g]');

data = importdata('test_7psi.lvm','\t',24);
data = data.data(:,2:4);

a_cg = data(:,1);
a_rear = data(:,2);
a_front = data(:,3);
t = (0:(length(a_cg)-1))/fs;

figure;
subplot(3,1,1);
plot(t,a_cg,'b');xlim([0 3]);ylim([-20 20]);
title('7 psi');
xlabel('Time [sec]');
ylabel('a_{cg} [g]');
subplot(3,1,2);
plot(t,a_rear,'r');xlim([0 3]);ylim([-20 20]);
xlabel('Time [sec]');
ylabel('a_{rear} [g]');
subplot(3,1,3);
plot(t,a_front,'k');xlim([0 3]);ylim([-20 20]);
xlabel('Time [sec]');
ylabel('a_{front} [g]');



% %%filtragem
% 
% [b,a] = butter(4, fc/(fs/2));   % filtro Butterworth 4ª ordem
% 
% 
% for k = 1:size(arquivos,1)
% 
%     nome = arquivos{k,1};
%     press = arquivos{k,2};
% 
%     % --- Importação ---
%     data = importdata(nome, '\t', 24);
%     data = data.data(:,2:4);   % colunas dos acelerômetros
% 
%     a_cg    = data(:,1);
%     a_rear  = data(:,2);
%     a_front = data(:,3);
% 
%     t = (0:(length(a_cg)-1))/fs;
% 
%     % --- FILTRAGEM (zero-phase) ---
%     a_cg_f    = filtfilt(b,a,a_cg);
%     a_rear_f  = filtfilt(b,a,a_rear);
%     a_front_f = filtfilt(b,a,a_front);
% 
%     % --- Plot ---
%     figure;
%     sgtitle([num2str(press) ' psi – Sinais Filtrados']);
% 
%     subplot(3,1,1);
%     plot(t, a_cg_f,'b'); xlim([0 3]); ylim([-20 20]);
%     ylabel('a_{cg} [g]'); title('CG');
% 
%     subplot(3,1,2);
%     plot(t, a_rear_f,'r'); xlim([0 3]); ylim([-20 20]);
%     ylabel('a_{rear} [g]'); title('Rear');
% 
%     subplot(3,1,3);
%     plot(t, a_front_f,'k'); xlim([0 3]); ylim([-20 20]);
%     ylabel('a_{front} [g]'); xlabel('Time [sec]'); title('Front');
% 
%     % --- Salva em variáveis para comparação futura ---
%     dados(k).pressao = press;
%     dados(k).t = t;
%     dados(k).cg = a_cg_f;
%     dados(k).rear = a_rear_f;
%     dados(k).front = a_front_f;
% 
% end





