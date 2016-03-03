% Reads one data packet at a time and plots

clear all
A = ActiChamp;
while (1)
A.Go();
plot(A.EEGData)
drawnow
pause(0.01)
end
