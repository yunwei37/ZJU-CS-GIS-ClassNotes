# 阿里巴巴编程之夏项目提案

- 项目：Topology aware scheduling in cloud native multi-cluster/multi-cloud environments
- 社区：Open-Cluster-Management
- 申请人：郑昱笙

## 目录

<!-- TOC -->

- [目录](#目录)
- [项目名称及要求](#项目名称及要求)
  - [Topology aware scheduling in cloud native multi-cluster/multi-cloud environments](#topology-aware-scheduling-in-cloud-native-multi-clustermulti-cloud-environments)
  - [项目需求](#项目需求)
  - [技术要求](#技术要求)
  - [相关仓库](#相关仓库)
- [项目详细方案](#项目详细方案)
  - [原生K8S拓扑分布约束](#原生k8s拓扑分布约束)
    - [Filter解读](#filter解读)
    - [Score解读](#score解读)
  - [移植到OCM](#移植到ocm)
    - [Placement 原理](#placement-原理)
    - [Placement 改进](#placement-改进)
- [项目开发时间计划](#项目开发时间计划)
- [参考资料](#参考资料)

<!-- /TOC -->

## 项目名称及要求

### Topology aware scheduling in cloud native multi-cluster/multi-cloud environments

>In this project, the topology aware scheduling’s requirement is to support spread policy. Spread policy is used to control how workload are spread across your clusters failure-domains such as regions, zones, and other user-defined topology domains. For example, with spread policy, user can spread the workload to clusters with different regions as much as possible first, and then spread the workload to clusters with different zones as much as possible. The degree of how much the workload could be unevenly distributed is configurable.
>
>We want you to work together with OCM developers and the community, to deliver a proposal for this project. The proposal should include the API design and how the placement controller consumes the API. The proposal needs to be finally reviewed in OCM community meeting. Also, you need to deliver a prototype based on the proposal. The prototype should support topology spread policy, what’s more, you need to consider the performance and the scale capability in a large (thousands of) clusters environments.

### 项目需求

在OCM下实现**拓扑分布约束**（属于**拓扑感知调度**体系中的一部分）,需要关注在超大集群规模的环境中的性能和缩扩容能力。

目前来说，原生K8S中有一个[拓扑分布约束](https://kubernetes.io/zh-cn/docs/concepts/workloads/pods/pod-topology-spread-constraints/)的功能。而在OCM中，需要实现与之类似的机制，以在多集群环境中实现对[故障域](https://lethain.com/fault-domains)的分布管理。

### 技术要求

* 支撑K8S使用的基础知识
* 对K8S的调度流程、调度机制有一定的了解
* 对OCM的定位，以及多集群管理面临的问题背景有一定了解
* 了解OCM Placement的相关机制
* Go语言开发相关知识

### 相关仓库

* [GitHub: OCM/API](https://github.com/open-cluster-management-io/api) （OCM核心API）
* [GitHub: OCM/Placement](https://github.com/open-cluster-management-io/placement)（本次项目主要涉及的仓库）
* [GitHub: OCM/Enhancements](https://github.com/open-cluster-management-io/enhancements)（已有的提案的例子，以及后续对于API在社区上的公开讨论）
* [GitHub: OCM/Community](https://github.com/open-cluster-management-io/community)（关于如何更改API的流程）


## 项目详细方案

项目的目标是实现一个**拓扑分布约束**（所以需要对比原生K8S实现，设计基于OCM的方案）。

### 原生K8S拓扑分布约束

在原生K8S中，拓扑分布约束是**基于用户自定义的拓扑域**实现，API的输入分为：

* 目标拓扑域：`topologyKey`
* 不满足约束时的处理：`whenUnsatisfiable`（包括`ScheduleAnyway`和`DoNotSchedule`）
* 标签选择器：`labelSelector`
* 允许的最大分布不均程度：`maxSkew`
* (Optional) 全局最小域机制：`minDomains`

参考原生K8S的[调度框架](https://kubernetes.io/zh-cn/docs/concepts/scheduling-eviction/scheduling-framework/)相关文档，一个调度上下文由`PreFilter`, `Filter`, `PostFilter`, `PreScore`, `Score`, `NormalizeScore`一连串的队列流程组成。

为了不满足约束时的处理的两种不同策略（选择影响倾斜程度最小化和不调度的控制），结合其文档中描述的逻辑，实际上该插件是要由`Scoring`和`Filtering`两部分组成，对应到[Pod Topology Spread Plugin](https://github.com/kubernetes/kubernetes/tree/master/pkg/scheduler/framework/plugins/podtopologyspread)这个目录的`scoring.go`和`filtering.go`两部分

结合代码，主要是实现了 [scheduler/framework/interface.go](https://github.com/kubernetes/kubernetes/blob/master/pkg/scheduler/framework/interface.go) 的 `Score` 相关的接口和 `Filter` 相关接口，下面结合接口和该插件的实现进行代码解析：

#### Filter解读

Filter主要包含了从预处理筛选器的信息，并即时根据Pod数量的变化，做出对缓存状态更新，然后进行筛选的一系列过程。

官方文档中的释义如下：

> ### PreFilter
>
> 这些插件用于预处理 Pod 的相关信息，或者检查集群或 Pod 必须满足的某些条件。 如果 PreFilter 插件返回错误，则调度周期将终止
>
> ### Filter
>
> 这些插件用于过滤出不能运行该 Pod 的节点。对于每个节点， 调度器将按照其配置顺序调用这些过滤插件。如果任何过滤插件将节点标记为不可行， 则不会为该节点调用剩下的过滤插件。节点可以被同时进行评估。

接口主要定义如下：

```go
type PreFilterPlugin interface {
	Plugin
    // 预处理Pod相关信息，在该插件中“改变”插件的状态。是一个“信息扩展点”。
	PreFilter(ctx context.Context, state *CycleState, p *v1.Pod) (*PreFilterResult, *Status)
    // 当Pod的数量变化时，对自己目前持有的状态进行更新。
	PreFilterExtensions() PreFilterExtensions
}

// 响应Pod数量变化时的状态更改
type PreFilterExtensions interface {
	AddPod(ctx context.Context, state *CycleState, podToSchedule *v1.Pod, podInfoToAdd *PodInfo, nodeInfo *NodeInfo) *Status
	RemovePod(ctx context.Context, state *CycleState, podToSchedule *v1.Pod, podInfoToRemove *PodInfo, nodeInfo *NodeInfo) *Status
}

type FilterPlugin interface {
	Plugin
    // 依照上一步预处理好的状态，开始真正地进行过滤，
	Filter(ctx context.Context, state *CycleState, pod *v1.Pod, nodeInfo *NodeInfo) *Status
}

```

下面结合[PodTopologySpread插件的源码 -- filtering.go](https://github.com/kubernetes/kubernetes/blob/master/pkg/scheduler/framework/plugins/podtopologyspread/filtering.go)进行分析：

PreFilter的主要实现：

```go
func (pl *PodTopologySpread) PreFilter(ctx context.Context, cycleState *framework.CycleState, pod *v1.Pod) (*framework.PreFilterResult, *framework.Status) {
    // 在该拓扑扩展约束插件中，预处理节点信息
    // 填充并返回一个 preFilterState 结构体
	s, err := pl.calPreFilterState(ctx, pod)
	if err != nil {
		return nil, framework.AsStatus(err)
	}
    // 向缓存写入当前状态
	cycleState.Write(preFilterStateKey, s)
	return nil, nil
}

// 存储关于拓扑扩展约束的关键信息
type preFilterState struct {
	Constraints []topologySpreadConstraint
    // criticalPaths[0].MatchNum 表示最小匹配数量
    // criticalPaths[1].MatchNum 一定会大于等于上面的最小匹配数量，但不一定是第二小的匹配数量
	TpKeyToCriticalPaths map[string]*criticalPaths
    // topologyKey -> number of domains
	TpKeyToDomainsNum map[string]int
    // topologyPair: (topologyKey, pod_label(s)) -> number of matching pods
	TpPairToMatchNum map[topologyPair]int
}

```

PreFilterExtensions中，对于Pod数量改变时如何拉取缓存自动更新Plugin State的逻辑，是关于整个插件能高效运作的关键代码。

```go
func (pl *PodTopologySpread) AddPod(ctx context.Context, cycleState *framework.CycleState, podToSchedule *v1.Pod, podInfoToAdd *framework.PodInfo, nodeInfo *framework.NodeInfo) *framework.Status {
	// 在该插件中，AddPod和RemovePod的过程相似，都是先调用pl.getPreFilterState()获取CycleState缓存的状态，然后调用updateWithPod，对缓存的拓扑状态进行更新。
	// CycleState 可以理解为是状态的缓存，如果每次调起该插件都需要重新计算目前整个集群的拓扑状态很明显效率很低，所以才会引入这个机制，后续的性能优化和改进，也要考虑使用这个缓存机制。
	s, err := getPreFilterState(cycleState)
	if err != nil {
		return framework.AsStatus(err)
	}
	// 在updateWithPod中，对当前更改的delta值，重新计算目前插件的State并存入缓存
	s.updateWithPod(podInfoToAdd.Pod, podToSchedule, nodeInfo.Node(), 1)
	return nil
}

```

Filter的最后一步：挑掉不会进行Schedule的Pod（每个Pod将分别通过此Filter）

```go
func (pl *PodTopologySpread) Filter(ctx context.Context, cycleState *framework.CycleState, pod *v1.Pod, nodeInfo *framework.NodeInfo) *framework.Status {
    node := nodeInfo.Node()
    if node == nil {
        return framework.AsStatus(fmt.Errorf("node not found"))
    }

    // 拉取缓存
    s, err := getPreFilterState(cycleState)
    if err != nil {
        return framework.AsStatus(err)
    }

    // However, "empty" preFilterState is legit which tolerates every toSchedule Pod.
    if len(s.Constraints) == 0 {
        // 没有任何约束
        return nil
    }

    // 当前Pod的所有标签
    podLabelSet := labels.Set(pod.Labels)
    
    for _, c := range s.Constraints {
        // 约束的对应拓扑域
        tpKey := c.TopologyKey
        // 约束条件的标签
        tpVal, ok := node.Labels[c.TopologyKey]

        if !ok {
            klog.V(5).InfoS("Node doesn't have required label", "node", klog.KObj(node), "label", tpKey)
            // 对于不是目标拓扑域的，停止使用本插件进行过滤
            // UnschedulableAndUnresolvable 表示不做出任何改变
            return framework.NewStatus(framework.UnschedulableAndUnresolvable, ErrReasonNodeLabelNotMatch)
        }

        // judging criteria:
        // 'existing matching num' + 'if self-match (1 or 0)' - 'global minimum' <= 'maxSkew'
        // minMatchNum 
        minMatchNum, err := s.minMatchNum(tpKey, c.MinDomains, pl.enableMinDomainsInPodTopologySpread)
        if err != nil {
            klog.ErrorS(err, "Internal error occurred while retrieving value precalculated in PreFilter", "topologyKey", tpKey, "paths", s.TpKeyToCriticalPaths)
            continue
        }

        selfMatchNum := 0
        // 与定义的LabelSelector进行匹配
        if c.Selector.Matches(podLabelSet) {
            // 命中
            selfMatchNum = 1
        }
        // 获取缓存中，拓扑域和标签均相同的Pod数量
        pair := topologyPair{key: tpKey, value: tpVal}
        matchNum := 0
        if tpCount, ok := s.TpPairToMatchNum[pair]; ok {
            // 算上缓存里的数量
            matchNum = tpCount
        }
        skew := matchNum + selfMatchNum - minMatchNum
        if skew > int(c.MaxSkew) {
            klog.V(5).InfoS("Node failed spreadConstraint: matchNum + selfMatchNum - minMatchNum > maxSkew", "node", klog.KObj(node), "topologyKey", tpKey, "matchNum", matchNum, "selfMatchNum", selfMatchNum, "minMatchNum", minMatchNum, "maxSkew", c.MaxSkew)
            // 对于超过允许的最大倾斜程度的情况，停止该Pod的调度过程
            return framework.NewStatus(framework.Unschedulable, ErrReasonConstraintsNotMatch)
        }
    }

    return nil
}

```

#### Score解读

Score主要包含了从预处理评分器的信息，并即时根据Pod数量的变化，做出对缓存状态更新，然后对已经通过Filter的Pod进行排序的一系列过程。

官方文档中的释义如下：

>### PreScore
>
>这些插件用于执行 “前置评分（pre-scoring）” 工作，即生成一个可共享状态供 Score 插件使用。 如果 PreScore 插件返回错误，则调度周期将终止。
>
>### Score[ ](https://kubernetes.io/zh-cn/docs/concepts/scheduling-eviction/scheduling-framework/#scoring)
>
>这些插件用于对通过过滤阶段的节点进行排序。调度器将为每个节点调用每个评分插件。 将有一个定义明确的整数范围，代表最小和最大分数。 在[标准化评分](https://kubernetes.io/zh-cn/docs/concepts/scheduling-eviction/scheduling-framework/#normalize-scoring)阶段之后，调度器将根据配置的插件权重 合并所有插件的节点分数。
>
>### NormalizeScore
>
>这些插件用于在调度器计算 Node 排名之前修改分数。 在此扩展点注册的插件被调用时会使用同一插件的 [Score](https://kubernetes.io/zh-cn/docs/concepts/scheduling-eviction/scheduling-framework/#scoring) 结果。 每个插件在每个调度周期调用一次。



```go
type PreScorePlugin interface {
	Plugin
    // 类似于PreFilter，也是个预处理的Callback的信息扩展点。
	PreScore(ctx context.Context, state *CycleState, pod *v1.Pod, nodes []*v1.Node) *Status
}

type ScorePlugin interface {
	Plugin
    // 同样将在每一个被筛选出来的节点上被调用，需要输出该节点的分数值
	Score(ctx context.Context, state *CycleState, p *v1.Pod, nodeName string) (int64, *Status)
	ScoreExtensions() ScoreExtensions
}

type ScoreExtensions interface {
    // 计算Node排名之前，对所有的计算结果进行后处理。
	NormalizeScore(ctx context.Context, state *CycleState, p *v1.Pod, scores NodeScoreList) *Status
}
```

下面结合[PodTopologySpread插件的源码 -- scoring.go](https://github.com/kubernetes/kubernetes/blob/master/pkg/scheduler/framework/plugins/podtopologyspread/scoring.go)进行分析：

```go
// preScoreState 用于保存分数计算的缓存
// 比如当配置 ScheduleAnyway 时，选择最小化地影响倾斜程度的Node进行调度
// 这时候就要计算分数
type preScoreState struct {
    Constraints []topologySpreadConstraint
    // 不与Constraints匹配的topologyKey的节点名称
    IgnoredNodes sets.String
    // topologyPair: (topologyKey, node_label(s)) -> number of matching pods
    TopologyPairToPodCounts map[topologyPair]*int64
    // TopologyNormalizingWeight 对于每个拓扑域的分数计算权重（根据影响Skew的程度）
    // 实现的算法，将尽量的公平，能将确保小的拓扑域不会被其他很大的拓扑域直接淹没（比如在分数上被碾压）
    TopologyNormalizingWeight []float64
}

// PreScore 构造并填充preScoreState结构体，并存入缓存
func (pl *PodTopologySpread) PreScore(
    ctx context.Context,
    cycleState *framework.CycleState,
    pod *v1.Pod,
    filteredNodes []*v1.Node,
) *framework.Status {
    allNodes, err := pl.sharedLister.NodeInfos().List()
    if err != nil {
        return framework.AsStatus(fmt.Errorf("getting all nodes: %w", err))
    }

    if len(filteredNodes) == 0 || len(allNodes) == 0 {
        // No nodes to score.
        return nil
    }

    state := &preScoreState{
        IgnoredNodes:            sets.NewString(),
        TopologyPairToPodCounts: make(map[topologyPair]*int64),
    }

    // 如果是用非系统默认的拓扑分布规则，那么所有的 Nodes 都要有拓扑标签。
    // 否则，允许没有 可用区标签 的 Nodes 依然有基于主机名的拓扑标签。
    requireAllTopologies := len(pod.Spec.TopologySpreadConstraints) > 0 || !pl.systemDefaulted
    err = pl.initPreScoreState(state, pod, filteredNodes, requireAllTopologies)
    if err != nil {
        return framework.AsStatus(fmt.Errorf("calculating preScoreState: %w", err))
    }

    // 若当前Pod没有软拓扑分布约束，则直接返回
    if len(state.Constraints) == 0 {
        cycleState.Write(preScoreStateKey, state)
        return nil
    }

    // 当前Pod的节点亲和性要求（为了兼容节点亲和性插件）
    requiredNodeAffinity := nodeaffinity.GetRequiredNodeAffinity(pod)
    // 构造函数平行处理所有Node
    processAllNode := func(i int) {
        nodeInfo := allNodes[i]
        node := nodeInfo.Node()
        if node == nil {
            return
        }

        if !pl.enableNodeInclusionPolicyInPodTopologySpread {
            // `node` 需要同时满足该 Pod 的 NodeSelector/NodeAffinity 选项
            if match, _ := requiredNodeAffinity.Match(node); !match {
                return
            }
        }

        // 所有的拓扑域Key都必须要出现在`node`的标签里。
        if requireAllTopologies && !nodeLabelsMatchSpreadConstraints(node.Labels, state.Constraints) {
            return
        }

        for _, c := range state.Constraints {
            if pl.enableNodeInclusionPolicyInPodTopologySpread &&
            !c.matchNodeInclusionPolicies(pod, node, requiredNodeAffinity) {
                continue
            }

            pair := topologyPair{key: c.TopologyKey, value: node.Labels[c.TopologyKey]}
            // 如果 (topologyKey, node_labels) 对应的 Pod 数量没有被记录，则略过本次计算
            // 每个 Node 的 Count 数量，也将在推后到 Score() 函数中进行
            tpCount := state.TopologyPairToPodCounts[pair]
            if tpCount == nil {
                continue
            }
            count := countPodsMatchSelector(nodeInfo.Pods, c.Selector, pod.Namespace)
            atomic.AddInt64(tpCount, int64(count))
        }
    }
    pl.parallelizer.Until(ctx, len(allNodes), processAllNode)

    cycleState.Write(preScoreStateKey, state)
    return nil
}

```

initPreScoreState：初始化Score状态

```go
// 对所有已经经过筛选的节点进行迭代。筛选出没有指定拓扑域(topologyKey)的节点，为他们进行初始化
// 1) s.TopologyPairToPodCounts: 拓扑域，节点名称 -> Pod数量
// 2) s.IgnoredNodes: 将跳过评分的节点名称列表
// 3) s.TopologyNormalizingWeight: 每一个约束对应的权重（基于这个拓扑域中的值数量）
func (pl *PodTopologySpread) initPreScoreState(s *preScoreState, pod *v1.Pod, filteredNodes []*v1.Node, requireAllTopologies bool) error {
    var err error
    if len(pod.Spec.TopologySpreadConstraints) > 0 {
        // 筛选所有 whenUnsatisfiable 为 ScheduleAnyway 的所有约束
        // DoNotSchedule 的当然没必要进入到 Score 的流程里来
        s.Constraints, err = filterTopologySpreadConstraints(
            pod.Spec.TopologySpreadConstraints,
            v1.ScheduleAnyway,
            pl.enableMinDomainsInPodTopologySpread,
            pl.enableNodeInclusionPolicyInPodTopologySpread,
        )
        if err != nil {
            return fmt.Errorf("obtaining pod's soft topology spread constraints: %w", err)
        }
    } else {
        // 构建默认的约束
        s.Constraints, err = pl.buildDefaultConstraints(pod, v1.ScheduleAnyway)
        if err != nil {
            return fmt.Errorf("setting default soft topology spread constraints: %w", err)
        }
    }
    if len(s.Constraints) == 0 {
        return nil
    }
    topoSize := make([]int, len(s.Constraints))
    for _, node := range filteredNodes {
        if requireAllTopologies && !nodeLabelsMatchSpreadConstraints(node.Labels, s.Constraints) {
            // 如果当前 Node 的标签和约束中要求的标签并未全部匹配，则加入忽略列表
            s.IgnoredNodes.Insert(node.Name)
            continue
        }
        for i, constraint := range s.Constraints {
            // 后续在 Score() 的过程中会计算每个 Node 的 Pod 数量，这里不计算
            if constraint.TopologyKey == v1.LabelHostname {
                continue
            }
            pair := topologyPair{key: constraint.TopologyKey, value: node.Labels[constraint.TopologyKey]}
            if s.TopologyPairToPodCounts[pair] == nil {
                s.TopologyPairToPodCounts[pair] = new(int64)
                // 命中，计数
                topoSize[i]++
            }
        }
    }

    // 前面提到的基于主机名的拓扑标签在此进行处理
    s.TopologyNormalizingWeight = make([]float64, len(s.Constraints))
    for i, c := range s.Constraints { 
        // 获取当前 Node 的计数值
        sz := topoSize[i]
        // 如果拓扑域 Key 就是主机名
        if c.TopologyKey == v1.LabelHostname {
            // TopologyKey就是主机名的节点在前面的并未参与计算，这里需要算Size
            // 因为所有经过Filter筛选的节点，去掉了已经忽略的节点，剩下的就是这些拓扑域Key==主机名的节点
            sz = len(filteredNodes) - len(s.IgnoredNodes)
        }
        // 这里对size取了log(size+2)，由于k8s支持5000个Nodes，所以这样可以把结果控制在 <1.09, 8.52>
        // 如果所有节点都没有对应的拓扑域，size将会是0
        s.TopologyNormalizingWeight[i] = topologyNormalizingWeight(sz)
    }
    return nil
}

```

Score：计算Pod数量

```go
// 返回所有和 `nodeName` 匹配的 Pod 数量，在此之后才会进行标准化得分。
func (pl *PodTopologySpread) Score(ctx context.Context, cycleState *framework.CycleState, pod *v1.Pod, nodeName string) (int64, *framework.Status) {
    nodeInfo, err := pl.sharedLister.NodeInfos().Get(nodeName)
    if err != nil {
        return 0, framework.AsStatus(fmt.Errorf("getting node %q from Snapshot: %w", nodeName, err))
    }

    node := nodeInfo.Node()
    s, err := getPreScoreState(cycleState)
    if err != nil {
        return 0, framework.AsStatus(err)
    }

    // 不需要计算的 Node，跳过
    if s.IgnoredNodes.Has(node.Name) {
        return 0, nil
    }

    // For each present <pair>, current node gets a credit of <matchSum>.
    // And we sum up <matchSum> and return it as this node's score.
    var score float64
    for i, c := range s.Constraints {
        if tpVal, ok := node.Labels[c.TopologyKey]; ok {
            var cnt int64
            if c.TopologyKey == v1.LabelHostname {
                // 主机名作为拓扑域，计算所有同一个 Namespace 的 Pod 数量
                cnt = int64(countPodsMatchSelector(nodeInfo.Pods, c.Selector, pod.Namespace))
            } else {
                // 取出 (TopologyKey, NodeName) 的 Pod 数量
                pair := topologyPair{key: c.TopologyKey, value: tpVal}
                cnt = *s.TopologyPairToPodCounts[pair]
            }
            // += cnt * weight + (MaxSkew - 1)
            score += scoreForCount(cnt, c.MaxSkew, s.TopologyNormalizingWeight[i])
        }
    }
    return int64(math.Round(score)), nil
}
```

NormalizeScore：标准化得分

```go
// 标准化得分
func (pl *PodTopologySpread) NormalizeScore(ctx context.Context, cycleState *framework.CycleState, pod *v1.Pod, scores framework.NodeScoreList) *framework.Status {
    s, err := getPreScoreState(cycleState)
    if err != nil {
        return framework.AsStatus(err)
    }
    if s == nil {
        return nil
    }

    // 计算最值
    var minScore int64 = math.MaxInt64
    var maxScore int64
    for i, score := range scores {
        // score.Name 必须不能出现在 IgnoredNodes 中
        if s.IgnoredNodes.Has(score.Name) {
            scores[i].Score = invalidScore
            continue
        }
        if score.Score < minScore {
            minScore = score.Score
        }
        if score.Score > maxScore {
            maxScore = score.Score
        }
    }

    for i := range scores {
        if scores[i].Score == invalidScore {
            scores[i].Score = 0
            continue
        }
        if maxScore == 0 {
            scores[i].Score = framework.MaxNodeScore
            continue
        }
        s := scores[i].Score
        // 分数与 weight 数成反相关
        scores[i].Score = framework.MaxNodeScore * (maxScore + minScore - s) / maxScore
    }
    return nil
}

```

### 移植到OCM

简单来说就是，OCM版，基于多集群环境的一个**拓扑分布约束**。

纵观OCM的`Placement`机制，从结果来看，最终是要生成一个 `PlacementDecision` ——包含选中的集群和具体的原因。

但是由于不同的是，“原生K8S是静态调度，OCM Placement是用的是动态调度”，所以更需要在此进行性能优化。

代码库：[GitHub: OCM/Placement](https://github.com/open-cluster-management-io/placement)

#### Placement 原理

`Placement`也是基于`Plugin`机制进行工作的，经过**预选器**和**优选器**，产生最后的选择结果 `PlacementDecision`。

对应到OCM的具体代码中，是其预选器和优选器的结合：

```go
// Plugin is the parent type for all the scheduling plugins.
type Plugin interface {
    Name() string
    // Set is to set the placement for the current scheduling.
    Description() string
    // RequeueAfter 返回希望的重新回到队列的时间
    RequeueAfter(ctx context.Context, placement *clusterapiv1beta1.Placement) PluginRequeueResult
}

// Fitler 筛选器
type Filter interface {
    Plugin

    // 返回经过筛选的clusters
    Filter(ctx context.Context, placement *clusterapiv1beta1.Placement, clusters []*clusterapiv1.ManagedCluster) PluginFilterResult
}

// Prioritizer 对应的是打分器（优选器）的概念，分数要求在 0~1 之间的浮点数。
type Prioritizer interface {
    Plugin

    // 分值计算，返回所有的以ClusterName为Key，值为分数的Map
    Score(ctx context.Context, placement *clusterapiv1beta1.Placement, clusters []*clusterapiv1.ManagedCluster) PluginScoreResult
}
```

预选器：参考`requiredClusterSelector`的实现，位于`pkg/plugins/predicate.go`。类似于`FilterPlugin`，负责筛选出符合条件目标的集群

```go
func (p *Predicate) Filter(
    ctx context.Context, placement *clusterapiv1beta1.Placement, clusters []*clusterapiv1.ManagedCluster) plugins.PluginFilterResult {

    // ...

    // 根据 label/claim selectors 构建筛选器，类似于原生K8S Schedule Framework中的 PreFilter 做的事情
    predicateSelectors := []predicateSelector{}
    for _, predicate := range placement.Spec.Predicates {
        // ...
        predicateSelectors = append(predicateSelectors, predicateSelector{
            labelSelector: labelSelector,
            claimSelector: claimSelector,
        })
    }

    // 逐个应用 selectors 进行匹配
    matched := []*clusterapiv1.ManagedCluster{}
    for _, cluster := range clusters {
        claims := getClusterClaims(cluster)
        for _, ps := range predicateSelectors {
            // ...
        }
    }

    return plugins.PluginFilterResult{
        Filtered: matched,
    }
}

```

优选器：参考`PrioritizerBalance`插件（`Decision`中被选中的集群次数越少的越优先被选中）。类似于`ScorePlugin`从给定的若干集群中，使用不同的策略打分，乘上权重因子进行累加，最后对分数进行排序后选择指定数目的最高得分的集群。

```go
func (b *Balance) Score(ctx context.Context, placement *clusterapiv1beta1.Placement, clusters []*clusterapiv1.ManagedCluster) plugins.PluginScoreResult {
	scores := map[string]int64{}
	for _, cluster := range clusters {
		scores[cluster.Name] = plugins.MaxClusterScore
	}
	// 获取已经存在的 Decision
	decisions, err := b.handle.DecisionLister().List(labels.Everything())
	// ...

	var maxCount int64
	decisionCount := map[string]int64{}
	for _, decision := range decisions {
		// 跳过已经被 Schedule 的 Cluster 并计算 maxCount 和 decisionCount ( ClusterName -> Count )
		// ...
	}

	for clusterName := range scores {
		if count, ok := decisionCount[clusterName]; ok {
			usage := float64(count) / float64(maxCount)

			// decisionCount 越大，分值越少
			scores[clusterName] = 2 * int64(float64(plugins.MaxClusterScore)*(0.5-usage))
		}
	}

	return plugins.PluginScoreResult{
		Scores: scores,
	}
}
```

#### Placement 改进

在上述的代码的例子中，`Score()` 和 `Filter()` 的过程，在每次计算的时候，都会将整个多集群的状态进行重复计算，比起原生K8S的代码，没有用到相关的状态缓存机制。

在大规模的（10^3级别）多集群环境下，按每个Cluster最大Node数5000计算，Pod的数量变化会更加频繁。在 `Placement` 调度频次较高的环境下，在此会产生一定的性能瓶颈。

要进行大幅度的性能优化，先要对整个 `Placement API` 的流程进行优化。可以参考原生K8S调度周期框架，参考 `CycleState` 引入缓存机制和事件通知机制，缺点是工程量较大。

我们可能不能直接按照 k8s 官方文档中的拓扑约束中的 API 进行直接迁移，需要在社区上详细了解并且进一步讨论最适合 OCM 的 API 修改提案， 因为 API 的修改将涉及到多个层次以及整体上对 OCM 架构的影响。

## 项目开发时间计划

* [ ] 整理K8S拓扑分布约束的实现和`OCM Placement Controller`调用机制的实现相关代码（第一周）
* [ ] 参照目前已有的Placement Plugins和它们的提案，在已有的Placement API下，设计一个基本的**拓扑分布约束**功能，实现一个简单的**拓扑分布约束**的原型
  * [ ] 功能规划：结合原生K8S拓扑分布约束（目标拓扑域选择`TopologyKey`、不满足约束时的处理`whenUnsatisfiable`、标签选择器`labelSelector`、允许分布不均程度`maxSkew`、全局最小域机制`minDomains`）进行功能设计并编写 CRD（第二周）
  * [ ] 代码实现：参考原生K8S拓扑分布约束相关代码，实现`Placement`的`Filter`和`Prioritizer`插件接口（第二周）
  * [ ] 测试用例：编写`Placement`的拓扑分布约束的单元测试和集成测试用例（第三周）
  * [ ] 性能测试：使用`Profiling`和`Benchmark`进行简单的性能测试（第三周）

* [ ] 在社区上对其将面临的性能瓶颈进行公开讨论（讨论是否需要对Placement API的整个机制进行改造，以及改造的程度）（第四周）
* [ ] 根据讨论的结果做出改造和基于新`Placement API`机制实现**拓扑分布约束**（第四周-第五周）
* [ ] 使用工具模拟并评估**拓扑分布约束**在大规模集群环境下调度的性能（第五周）
* [ ] 后续进行更进一步的修改和优化（第五周-之后）

## 参考资料

[SOFASTACK: 还在为多集群管理烦恼吗？OCM来啦！](https://www.sofastack.tech/blog/still-worried-about-multi-cluster-management/)

[阿里系统软件技术: CNCF 沙箱项目 OCM Placement 多集群调度指南](https://www.cnblogs.com/alisystemsoftware/p/15924521.html)

[kubernetes.io: 控制节点上的拓扑管理策略](https://kubernetes.io/zh-cn/docs/tasks/administer-cluster/topology-manager/)

[kubernetes.io: 拓扑分布约束](https://kubernetes.io/zh-cn/docs/concepts/workloads/pods/pod-topology-spread-constraints/)

[OCM Official: Placement](https://open-cluster-management.io/concepts/placement/)

[kind: Quick Start](https://kind.sigs.k8s.io/docs/user/quick-start/)



