class AIPlayer:
    """
    AI 玩家
    """
    weight = [
        [70, -20, 20, 20, 20, 20, -15, 70], 
	    [-20,-30,5,5,5,5,-30,-15], 
	    [20,5,1,1,1,1,5,20],
	    [20,5,1,1,1,1,5,20],
	    [20,5,1,1,1,1,5,20],
        [20,5,1,1,1,1,5,20],
	    [-20,-30,5,5,5,5,-30,-15],
	    [70,-15,20,20,20,20,-15,70]
    ]

    deepth = 0

    maxdeepth = 6
    emptylistFlag = 10000000

    def __init__(self, color):
        """
        玩家初始化
        :param color: 下棋方，'X' - 黑棋，'O' - 白棋
        """

        self.color = color

    def calculate(self,board,color):
        if color == 'X':
            colorNext ='O'
        else:
            colorNext ='X'
        count = 0
        for i in range(8):
            for j in range(8):
                if color == board[i][j]: 
                    count += self.weight[i][j]
                elif colorNext == board[i][j]:
                    count -= self.weight[i][j]
        return count

    def alphaBeta(self,board,color,a,b):
        # 递归终止
        if self.deepth > self.maxdeepth:
                return None, self.calculate(board,self.color)

        if color == 'X':
            colorNext ='O'
        else:
            colorNext ='X'
        action_list = list(board.get_legal_actions(color))
        if len(action_list) == 0:
            if len(list(board.get_legal_actions(colorNext))) == 0:
                return None,self.calculate(board,self.color)
            return self.alphaBeta(board,colorNext,a,b)
        
        max = -9999999
        min = 9999999
        action = None

        for p in action_list:

            flipped_pos = board._move(p,color)
            self.deepth += 1
            p1, current = self.alphaBeta(board,colorNext,a,b)
            self.deepth -= 1
            board.backpropagation(p,flipped_pos,color)
            # print(p,current)
            # alpha-beta 剪枝
            if color == self.color:
                if current > a:
                    if current > b:
                        return p,current
                    a = current
                if current > max:
                    max = current
                    action = p

            else:
                if current < b:
                    if current < a:
                        return p,current
                    b = current
                if current < min:
                    min = current
                    action = p

        # print(color,action,max,min)

        if color == self.color:
            return action,max
        else:
            return action,min         


    def get_move(self, board):
        """
        根据当前棋盘状态获取最佳落子位置
        :param board: 棋盘
        :return: action 最佳落子位置, e.g. 'A1'
        """
        if self.color == 'X':
            player_name = '黑棋'
        else:
            player_name = '白棋'
        print("请等一会，对方 {}-{} 正在思考中...".format(player_name, self.color))

        # -----------------请实现你的算法代码--------------------------------------
        action_list = list(board.get_legal_actions(self.color))
        
        # action, weight = self.maxMin(board,self.color)
        action, weight = self.alphaBeta(board,self.color,-9999999,9999999)

        if len(action_list) == 0:
            return None
        print(action_list)
        print(action)
        return action
        # ------------------------------------------------------------------------


