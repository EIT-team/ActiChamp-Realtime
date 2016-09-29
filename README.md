# ActiChamp-Realtime

MATLAB code for streaming data from actiCHamp EEG system over TCP.

Example usage:


**Initialise object**

Acti = Actichamp; 

**Set IP address of actiCHamp**

Acti.ip = '12.34.56.78';

**Record 1 second of data**

Acti.Go(1);

data = Acti.data_buf;
