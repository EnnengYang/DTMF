# DTMF
[Discrete Trust-aware Matrix Factorization for Fast Recommendation. IJCAI, 2019.](https://www.ijcai.org/proceedings/2019/191)

## Abstract
> Trust-aware recommender systems have received much attention recently for their abilities to capture the influence among connected users. However, they suffer from the efficiency issue due to large amount of data and time-consuming real-valued operations. Although existing discrete collaborative filtering may alleviate this issue to some extent, it is unable to accommodate social influence. In this paper we propose a discrete trust-aware matrix factorization (DTMF) model to take dual advantages of both social relations and discrete technique for fast recommendation. Specifically, we map the latent representation of users and items into a joint hamming space by recovering the rating and trust interactions between users and items. We adopt a sophisticated discrete coordinate descent (DCD) approach to optimize our proposed model. In addition, experiments on two real-world datasets demonstrate the superiority of our approach against other state-of-the-art approaches in terms of ranking accuracy and efficiency.


## Citation

Please cite our paper if you use this code.

```
@inproceedings{ijcai2019-191,
   title     = {Discrete Trust-aware Matrix Factorization for Fast Recommendation},
   author    = {Guo, Guibing and Yang, Enneng and Shen, Li and Yang, Xiaochun and He, Xiaodong},
   booktitle = {Proceedings of the Twenty-Eighth International Joint Conference on
                Artificial Intelligence, {IJCAI-19}},
   publisher = {International Joint Conferences on Artificial Intelligence Organization},             
   pages     = {1380--1386},
   year      = {2019},
   month     = {7}
}

```


## DataSet
- Download  Epinions-665k | Douban, put it in the dataset directory.


##  Train and Evaluate Method

  ```
    setup.m
  ```

  ```
    testing.m
  ```


# Acknowledgement
[DefuLian/recsys](https://github.com/DefuLian/recsys)

Thanks them for providing efficient implementation.
