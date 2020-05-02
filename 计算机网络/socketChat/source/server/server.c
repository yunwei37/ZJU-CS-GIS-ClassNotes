#include "../socketChat.h"
#include "data.h"

void *thread_function(void *arg);

//char message[] = "Hello World";
//int thread_finished = 0;

pthread_mutex_t work_mutex;

int acceptnum=0;

void newAcceptT(clientData *data){
        int res;
    pthread_t a_thread;
    pthread_attr_t thread_attr;

    res = pthread_attr_init(&thread_attr);
    if (res != 0) {
        perror("Attribute creation failed\n");
        exit(EXIT_FAILURE);
    }
    res = pthread_attr_setdetachstate(&thread_attr, PTHREAD_CREATE_DETACHED);
    if (res != 0) {
        perror("Setting detached attribute failed\n");
        exit(EXIT_FAILURE);
    }
    res = pthread_create(&a_thread, &thread_attr, thread_function, (void *)data);
    if (res != 0) {
        perror("Thread creation failed\n");
        exit(EXIT_FAILURE);
    }
}

char* getCurTime(){
    time_t t1;
    t1=time(&t1);
    return ctime(&t1);
}

void *exitfunction(void *arg){
    int i=1;
    printf("exit: enter 0\n");
    while(i)
        scanf("%d",&i);
    exit(0);
}

int main() {

    int res = pthread_mutex_init(&work_mutex, NULL);
    if (res != 0) {
        perror("Mutex initialization failed");
        exit(EXIT_FAILURE);
    }

    int server_sockfd, client_sockfd;
    int server_len, client_len;
    struct sockaddr_in server_address;
    struct sockaddr_in client_address;

    server_sockfd = socket(AF_INET, SOCK_STREAM, 0);

    server_address.sin_family = AF_INET;
    server_address.sin_addr.s_addr = htonl(INADDR_ANY);
    server_address.sin_port = htons(2760);
    server_len = sizeof(server_address);
    bind(server_sockfd, (struct sockaddr *)&server_address, server_len);

/*  Create a connection queue, ignore child exit details and wait for clients.  */

    listen(server_sockfd, 5);

    pthread_t killthread;
    res = pthread_create(&killthread, NULL, exitfunction, (void *)0);
    if (res != 0) {
        perror("Thread creation failed\n");
        exit(EXIT_FAILURE);
    }

    while(1) {

        printf("server waiting\n");

/*  Accept connection.  */

        client_len = sizeof(client_address);
        client_sockfd = accept(server_sockfd, 
            (struct sockaddr *)&client_address, &client_len);
        printf("accept num = %d\n",acceptnum++);
        
        clientData* data=malloc(sizeof(clientData));
        data->acceptnum=acceptnum;
        data->clientfd=client_sockfd;
        strcpy(data->ipaddress, inet_ntoa( client_address.sin_addr));
        data->port=client_address.sin_port;
        
        pthread_mutex_lock(&work_mutex);
        addclient(*data);
        pthread_mutex_unlock(&work_mutex);

        newAcceptT(data);
    }

    exit(EXIT_SUCCESS);
}

void *thread_function(void *arg) {
    int client_sockfd=((clientData*)arg)->clientfd;
    int destination;
    printf("thread_function is running. client_sockfd was %d\n", client_sockfd);
    int res;
    struct Message m={'h',0,client_sockfd,"hello from server"};
    sendMessage(&m,client_sockfd);
    char buffer1[1024];
    while(1){
        if(!getMessage(&m,client_sockfd)){  
                pthread_exit(NULL);
        }
        destination=client_sockfd;
        switch(m.type){
            case 'g': // get client dada
                pthread_mutex_lock(&work_mutex);
                res=getAllClientData(m.content,1024);
                pthread_mutex_unlock(&work_mutex);
                printf("totol char %d\n",res);
                break;
            case 'm': // send message to another client
                pthread_mutex_lock(&work_mutex);
                res=findClientfd(m.des); // find the client fileid by the client number
                pthread_mutex_unlock(&work_mutex);
                printf("sendto fd %d\n",res);
                strcpy(buffer1,m.content);
                sprintf(m.content,"from client: %d, message:\n%s\n",m.des,buffer1);
                if(res!=-1)
                    destination=res;
                else{
                    strcpy(m.content,"wrong code");
                    printf("wrong send code!\n");
                }                
                break;
            case 't': // get time and send to client
                strcpy(m.content,getCurTime());
                printf("gettime,from %d\n", client_sockfd);
                break;

            case 'n': // get name and send to client
                gethostname(m.content, BUFFER_SIZE);
                printf("gethostname,from %d, name: %s\n", client_sockfd, m.content);
                break;

            case 'q': // client disconnect
                printf("quit chat with %d", client_sockfd);
                sendMessage(&m,client_sockfd);
                close(client_sockfd); 
                pthread_mutex_lock(&work_mutex);
                res=removeClient(((clientData*)arg)->acceptnum);
                pthread_mutex_unlock(&work_mutex);               
                pthread_exit(NULL);
                break;
            default: // other: handle exception
                printf("unknown message!\n");
                continue;
                break;
        }
        //printf("from client: %s\n",m.content);
        //sleep(1);
        sendMessage(&m,destination);
	}
}
