#ifndef _DATA_H_
#define _DATA_H_

    typedef struct {
        int acceptnum;
        int clientfd;
        char ipaddress[20];
        int port;
    } clientData;

void addclient(clientData data);
int getAllClientData(char *buffer, int max);
int removeClient(int id);
int findClientfd(int id);


#endif