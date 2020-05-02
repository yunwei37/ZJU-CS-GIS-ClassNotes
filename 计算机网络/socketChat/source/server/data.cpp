#include<iostream>
#include<map>
#include "data.h"
#include "../socketChat.h"

using namespace std;

map<int, clientData> connection;
map<int, clientData>::iterator it;

void addclient(clientData data){
    connection[data.acceptnum] = data;
}

int getAllClientData(char *buffer, int max){
    int size, count=0;
    char* bufferbak=buffer;
    printf("total size: %d\n",size = connection.size()); // get the number of clients
    sprintf(buffer,"total size: %d\n",size);
    while(count < max && buffer[0]!='\n') // find the end of string
        buffer++, count++;
    buffer++,count++;
    buffer[0]=0;
    for(it = connection.begin();it != connection.end();it++){
        // get the message of each client
        sprintf(buffer,"clientid: %d , clinet address: %s ,client port: %d\n", it->first,it->second.ipaddress,it->second.port);
            while(count < max && buffer[0]!='\n')
                buffer++, count++;
            if(count >= max){
                printf("out of buffer in getAllClientData");
                return -1;
            }
            buffer++,count++;
            buffer[0]=0;    
    }
    printf("%s\n",bufferbak);
    return strlen(bufferbak); // return the length of total message
}

int removeClient(int id){
    if(connection.erase(id))
        return 1;
    return 0;
}

int findClientfd(int id){
    it=connection.find(id);
    if(it==connection.end())
        return -1;
    return it->second.clientfd;
}

