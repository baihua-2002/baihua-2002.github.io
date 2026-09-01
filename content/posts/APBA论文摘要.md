---
title: 'APBA：基于大语言模型的 ASPECT 参数文件自动生成系统及其在地幔对流模拟复现中的验证'
date: 2026-09-01
description: 'APBA 论文摘要'
summary: 'APBA 论文摘要：基于结构化知识供给、受约束生成与闭环修复的 ASPECT 参数文件自动生成系统，已端到端复现华北克拉通岩石圈热对流模型。'
tags: [论文摘要, 智能体, 数值模拟]
---

* 在王老师的指导下完成了初步工作。
* 本系统的源代码可见 https://github.com/baihua-2002/aspect_toolkit/

ASPECT（Advanced Solver for Planetary Evolution, Convection, and Tectonics，行星演化、对流与构造高级求解器）是一款采用 C++ 编写的可扩展软件，用于模拟地球和各类天体内部的对流动力学，为地球科学研究提供了一套文档详尽、结构清晰、便于二次开发的代码平台[1,2]。ASPECT 采用参数配置文件（.prm）驱动计算过程，该文件以节的层次嵌套组成树状结构的方式组织参数，具有层级深、参数多、约束复杂等特点，依靠人工编写和调试不仅成本高，也限制了进行验证实验和复现已有论文的速度。

近年来，以 Claude Code[3] 为代表的大语言模型驱动的编码智能体（Coding Agent）凭借预训练知识、工具调用与上下文推理能力[4]在软件工程、数学建模等领域表现良好[5]。但是，通用编码智能体在编写配置文件时仍面临诸多挑战。一方面，模型训练语料和智能体记忆系统缺少 ASPECT 参数和语法信息，相关文档又多为 HTML、PDF 等人类可读格式，难以直接转化为可检索、可校验的结构化知识；另一方面，人类自然语言描述的和具体参数之间的对应关系难以匹配，网络分辨率和计算成本之间的权衡也难以合理把握。

本文设计并实现了 ASPECT 参数文件构建智能体（ASPECT Parameter-file Builder Agent，APBA），一个基于结构化知识供给、受约束的参数文件生成和运行驱动的闭环修复机制的 ASPECT 参数文件构建系统。

**在结构化知识供给方面**，APBA 构建了包含 1594 条 ASPECT 官方参数定义和专家仿真案例的知识库，并将光学字符识别后的论文内容[6]按照统一的仿真案例模式进行结构化抽取；对于论文未明确说明的字段予以显式标记，同时将抽取得到的参数名称规范化对齐至其在 ASPECT 层级配置树的叶子结点中。系统采用「案例摘要检索—案例详情按需获取」的两级检索方式[7]，在控制上下文长度的同时[8]为参数选择提供官方定义、参考取值及其来源。

**在受约束的参数文件生成方面**，大语言模型与 APBA 系统的其他部分采用如下共识沟通：记 T 为参数配置文件树状结构对应的树，内部结点对应配置节，叶子结点对应参数，每个参数由根到叶的唯一路径标识。大语言模型不直接书写 `.prm` 文件，只输出对 T 的叶子结点的一个部分赋值，形成扁平的「参数—取值」清单；参数文件构建程序校验参数名称、类型与合法取值，将清单中路径的并集还原为 T 的含根子树，序列化为 .prm 文件，从而将参数决策与语法生成分离，使错误能够被准确定位和增量修改。各参数取值均记录来源依据，缺乏明确证据者标记为默认值或系统假设，保证可追溯性。

**在运行驱动的闭环修复方面**，智能体编排层将需求理解、知识检索、结构化生成、静态校验、文件组装和求解器运行组织为闭环；当静态校验或 ASPECT 运行失败时，连接器程序屏蔽操作系统和软件版本差异，将错误归类为未知参数、类型错误、非法取值或子节不匹配等类别，定位相关参数并进行最多三轮上下文友好的增量修复。

通过这些机制，APBA 能够从用户描述或现有论文中提取建模需求与意图，编写、调试参数配置文件并调用 ASPECT 执行模拟。目前已完成对论文《数值模拟华北克拉通岩石圈热对流侵蚀减薄机制》[6]中二维岩石圈热对流模型的端到端复现：智能体从论文中自动提取建模需求、生成参数文件并成功运行 ASPECT 获得模拟结果；与人工撰写的参数文件相比，两者温度场形态与平均温度等主要特征一致，差异主要源于网格加密策略与求解精度设置的不同，初步验证了系统的可行性。后续将选取更多已发表的地球内部对流动力学论文[9]开展系统性复现实验，评估参数提取准确率、平均修复轮次及与论文基准结果的误差，并通过消融实验考察知识库、参数决策与语法生成分离机制和多轮增量修复对智能体能力的贡献。本系统的源代码可见 <https://github.com/baihua-2002/aspect_toolkit>。

## 参考文献

- [1] Heister T, Dannberg J, Gassmöller R, et al. High accuracy mantle convection simulation through modern numerical methods – II: realistic models and problems[J]. Geophysical Journal International, 2017, 210(2): 833-851. DOI: 10.1093/gji/ggx195.
- [2] BANGERTH W, HARTMANN R, KANSCHAT G. deal.II—A general-purpose object-oriented finite element library[J]. ACM Transactions on Mathematical Software, 2007, 33(4): 24-es.
- [3] ANTHROPIC. Claude Code Documentation[EB/OL]. <https://docs.anthropic.com/en/docs/claude-code>.
- [4] YAO S, ZHAO J, YU D, et al. ReAct: Synergizing reasoning and acting in language models[C]//International Conference on Learning Representations (ICLR). 2023.
- [5] YANG J, JIMENEZ C E, WETTIG A, et al. SWE-agent: agent-computer interfaces enable automated software engineering[J]. Advances in Neural Information Processing Systems, 2024, 37: 50528-50652. DOI: 10.52202/079017-1601.
- [6] 乔彦超, 郭子祺, 石耀霖. 数值模拟华北克拉通岩石圈热对流侵蚀减薄机制[J]. 中国科学: 地球科学, 2013, 43(4): 642-652.
- [7] LEWIS P, PEREZ E, PIKTUS A, et al. Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks[C]//Advances in Neural Information Processing Systems (NeurIPS). 2020, 33: 9459-9474.
- [8] LIU N F, LIN K, HEWITT T, et al. Lost in the Middle: How Language Models Use Long Contexts[J]. Transactions of the Association for Computational Linguistics, 2024, 12: 157-173.
- [9] TACKLEY P J. Mantle convection and plate tectonics: Toward an integrated model[J]. Science, 2000, 288(5473): 2002-2007.
