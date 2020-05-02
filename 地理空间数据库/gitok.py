import sys


headline_dic={'#':0,'##':1,'###':2,'####':3,'#####':4,'######':5}
suojin={0:-1,1:-1,2:-1,3:-1,4:-1,5:-1,6:-1}
def writefile(fp, str=None):
    with open(fp,'w') as f:
        f.write(str)

def detectHeadLines(f):
    '''detact headline and return inserted string.
    params:
        f: Markdown file
    '''
    f.seek(0)

    insert_str=""
    org_str=""

    last_status = -1
    c_status=-1

    headline_counter=0
    iscode=False
    for line in f.readlines():
        if(line[:3]=='```'):
            iscode= not iscode
            
        # fix code indent bug.
        if not iscode:
            line=line.strip(' ')
        ls=line.split(' ')
        if len(ls)>1 and ls[0] in headline_dic.keys() and not iscode:
            headline_counter+=1
            c_status=headline_dic[ls[0]]
            # find first rank headline
            if last_status==-1 or c_status==0 or suojin[c_status]==0:
                # init suojin
                for key in suojin.keys():
                    suojin[key]=-1
                suojin[c_status]=0
            elif c_status>last_status:
                suojin[c_status]=suojin[last_status]+1
            
            # update headline text
            headtext=' '.join(ls[1:-1])
            if ls[-1][-1]=='\n':
                headtext+=(' '+ls[-1][:-1])
            else:
                headtext+=(' '+ls[-1])
            headid = '{}{}'.format('head',headline_counter)
            headline=ls[0]+' <span id=\"{}\"'.format(headid)+'>'+ headtext+'</span>'+'\n'
            org_str+=headline

            jump_str='- [{}](#{}{})'.format(headtext,'head',headline_counter)
            insert_str+=('\t'*suojin[c_status]+jump_str+'\n')
                    
            last_status=c_status
        else:
            org_str+=line
            
            
    return insert_str+org_str

    
    
if __name__=='__main__':

    filename = sys.argv[1]
    #print(filename)
    f = open(filename,'r',encoding='utf-8')
    insert_str=detectHeadLines(f)
    f.close()
    with open('{}_with_toc.md'.format(filename[:filename.find('.')]),'w',encoding='utf-8') as f:
        f.write(insert_str)