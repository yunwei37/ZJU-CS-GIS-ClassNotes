#include "../socketChat.h"

sem_t bin_sem;

struct Message m;

int connectedState=0;

void *thread_sender(void *arg);
void *thread_accepter(void *arg);

int testConnection(){
    if(!connectedState){
        printf("not connected!\n");
        return 1;
    }
    return 0;
}

int connectServer(char *serAddress,int port){

    int sockfd, len, result;
    struct sockaddr_in address;

/*  Create a socket for the client.  */
    sockfd = socket(AF_INET, SOCK_STREAM, 0);

/*  Name the socket, as agreed with the server.  */
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = inet_addr(serAddress);
    address.sin_port = htons(port);
    len = sizeof(address);

/*  connect our socket to the server's socket.  */
    result = connect(sockfd, (struct sockaddr *)&address, len);
    if(result == -1) {
        perror("oops: client3\n");
        return -1;
    }
	printf("connected\n");
    connectedState=1;
    return sockfd;
}

pthread_t newAcceptT(int sockfd, void *(*thread_function)(void *)){
    int res;
    pthread_t a_thread;

    res = pthread_create(&a_thread, NULL, thread_function, (void *)sockfd);
    if (res != 0) {
        perror("Thread creation failed\n");
        exit(EXIT_FAILURE);
    }
    return a_thread;
}

int main(int argc, char *argv[])
{   
    if(argc!=2){ 
        printf("usage: ./cli IPaddress");
        exit(0);
    }
    int i;
    void *thread_result;
    int sockfd;
    pthread_t accepterT;
    pthread_t senderT;
    while(1){
        printf("the client start:\n 0-> exit \n 1-> connect \n 2-> disconnect \n 3-> getTime \n 4-> getName \n 5-> sendMessage to \n 6-> get all clients\n");
        scanf("%d",&i);
        switch(i){
            case 0:
                if(testConnection())
                    exit(0);
                else
                    printf("must disconnect first!\n");
            case 1:
                if(connectedState){
                    printf("connected!");
                    continue;
                }
                m.type = 1; 
                sockfd = connectServer(argv[1],2760);
                if(sockfd==-1)
                    continue;
                accepterT = newAcceptT(sockfd,thread_accepter);
                senderT = newAcceptT(sockfd,thread_sender);
                int res = sem_init(&bin_sem, 0, 0);
                if (res != 0) {
                    perror("Semaphore initialization failed");
                    exit(EXIT_FAILURE);
                }               
                break;
            case 2: 
                    if(testConnection())
                        continue;
                    m.type='q';
                    m.content[0]=0;
                    sem_post(&bin_sem);
                    res = pthread_join(accepterT, &thread_result);
                    if (res != 0) {
                        perror("Thread join failed");
                        exit(EXIT_FAILURE);
                    }
                    res = pthread_join(senderT, &thread_result);
                    if (res != 0) {
                        perror("Thread join failed");
                        exit(EXIT_FAILURE);
                    }
                    sem_destroy(&bin_sem);                        
                    close(sockfd);
                    exit(0);
                break; 
            case 3:
                if(testConnection())
                    continue;
                m.type='t';
                m.content[0]=0;
                sem_post(&bin_sem);
                break;
            case 4:
                if(testConnection())
                    continue;
                m.type='n';
                m.content[0]=0;
                sem_post(&bin_sem);
                break; 
            case 5:
                if(testConnection())
                    continue;
                printf("enter message:  ");
                scanf("\n");
                fgets(m.content,BUFFER_SIZE,stdin);
                printf("enter the client id you want to send to:  ");
                scanf("%d",&m.des);
                m.type='m';
                sem_post(&bin_sem);
                break;
            case 6:
                if(testConnection())
                    continue;
                m.type='g';
                m.content[0]=0;
                sem_post(&bin_sem);
                break;
            default:
                printf("wrong enter, again\n");
                break;                                                  
        }
    }

}

/* the thread to receive message */
void *thread_accepter(void *arg) {
    int sockfd = (int)arg;

    while(1){
        struct Message m1;
        if(!getMessage(&m1,sockfd))
            exit(-1);
        if(m1.type=='q')
            pthread_exit(NULL);
        
    }
}

/* the thread to send message */
void *thread_sender(void *arg) {
    int sockfd = (int)arg;

    sem_wait(&bin_sem);
    while(1){
        sendMessage(&m,sockfd);
        if(m.type=='q')
            pthread_exit(NULL);
        sem_wait(&bin_sem);
    }
}
