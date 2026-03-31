# "Reduced order methods to approximate parametric PDEs" course for excellence programme at Castelnuovo in Sapienza
Repository of the excellence course on "Metodi ridotti per approssimare PDEs parametriche" at Castelnuovo in Sapienza by [Alessandro Alla](https://www.alessandroalla.com/) and [Davide Torlo](https://davidetorlo.it).


# Programme

| Topic | Slides | Notes | Code | Recordings |
|-------|------------|-------------|--------|-----|
| Finite difference for elliptic/parabolic problems | [pdf](./lectures/finite_difference.pdf) [html](https://html-preview.github.io/?url=https://github.com/accdavlo/excellence-MOR/blob/main/lectures/finite_difference.html) | [pdf](./notes/2026-03-17-Note-16-08.pdf) |[Matlab Code](./codes/matlab/finite_difference_parabolic.mlx) | [Audio](https://drive.google.com/drive/folders/1iOJq5Hj2XyEpOOdLpIJz0_G2D84OYQ3d?usp=sharing) |
| Proper Orthogonal Decomposition |[pdf](./lectures/Pod_svd.pdf) | [pdf](./notes/33CBM12-eBook.pdf) |[Matlab code](./codes/matlab/ac_2D.m)||
| DEIM/DMD | | [pdf](./lectures/DEIM.pdf)|||
| POD-NN and autoencoders | [pdf](./lectures/NN.pdf) [html](https://html-preview.github.io/?url=https://github.com/accdavlo/excellence-MOR/blob/main/lectures/NN.html) | [pdf](./notes/2026-03-31-Note.pdf)| [Matlab POD-NN](./codes/matlab/PODNN.m) [Autoencoder comparison](./codes/matlab/comparison_reduction.m)||

Functions for autoencoders in Matlab [Autoencoder](./codes/matlab/fun_autoencoder.m), [Convolutional Autoencoder](./codes/matlab/fun_convolutional_autoencoder_500.m), [discrete learning](./codes/matlab/fun_discrete_learning.m), [operator learning](./codes/matlab/fun_operator_learning.m)



# Schedule
The classes will be held at the new Centro di Calcolo Laboratory at ground floor of the Castelnuovo building. The schedule is as follows:

| Date | Time | Topic |
|------|------|-------|
|2026-03-17| 15:00-17:00 | Finite difference for elliptic/parabolic problems |
|2026-03-19 | 13:00-15:00 | Proper Orthogonal Decomposition |
|2026-03-26 | 11:00-13:00 | DEIM/DMD |
|2026-03-31 | 15:00-17:00 | POD-NN and autoencoders |


# References
1. [Alla's notes POD + EIM](./notes/33CBM12-eBook.pdf)
1. Hesthaven, J., Rozza G. and Stamm B. Certified Reduced Basis Methods for Parametrized Partial Differential Equations. Springer, 2016. [Riduzione del Modello] [https://link.springer.com/book/10.1007/978-3-319-22470-1](https://link.springer.com/book/10.1007/978-3-319-22470-1)
1. Convolutional autoencoders for MOR [Fresca Dede' Manzoni](https://link.springer.com/article/10.1007/s10915-021-01462-7)

# Project ideas
1. Heat equations with a more complex geometry and parametric diffusivity [see notebook](https://github.com/accdavlo/calcolo-scientifico/blob/main/codes/ROM_with_FEniCS.ipynb)
1. POD on Allen-Cahn with fixed random initial conditions and parametric diffusivity
1. Transport equation with parametric velocity field with POD vs autoencoder or other NNs
1. Pattern formations with autoencoders vs POD
1. Dynamic low rank approximation
1. Error estimators for reduced order models [Hesthaven's book]
