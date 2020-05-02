#include "socketChat.h"

void printMessage(struct Message* m){
        printf("type:%c\n",m->type);
        printf("l: %d\n",m->length);
        printf("destination: %d\n",m->des);
        printf("message: %s\n",m->content);
}

int wrapMessage(char *buffer,struct Message* msg){

    int l=strlen(msg->content)+sizeof(int)*3;
    if(l>MESSAGE_SIZE){
        perror("message out range\n");
        //exit(EXIT_FAILURE);
        return -1;
    }
    msg->length=l;

    memcpy(buffer,msg, msg->length);

    printf("prepare to send messgae:\n");
    printMessage(msg);

    return l;
}

int getMessage(struct Message* msg,int client_sockfd){
    int n=rio_readn(client_sockfd, msg, sizeof(int)*3);
    if(n!=sizeof(int)*3){
        close(client_sockfd);
        perror("Read head wrong\n");
        return 0;
        //exit(EXIT_FAILURE);
    }

    n += rio_readn(client_sockfd, msg->content ,  msg->length-sizeof(int)*3);

    if(n!=msg->length || n >= BUFFER_SIZE){
        close(client_sockfd);
        perror("Read content wrong\n");
        return 0;
        //exit(EXIT_FAILURE);
    }
    msg->content[n-sizeof(int)*3]=0;

    printf("receive message:\n");
    printMessage(msg);
    return 1;
}

int sendMessage(struct Message* msg, int sockfd){
    char buffer[BUFFER_SIZE];
    int n=wrapMessage(buffer,msg);
    rio_writen(sockfd, buffer, n);
    return n;
}