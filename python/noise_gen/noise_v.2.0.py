##-----------------------------------------------------------------------------

##-----------------------------------------------------------------------------
import matplotlib.pyplot as plt
import numpy as np
##-----------------------------------------------------------------------------


N = 12 ## количество суммирований
n = 16 ## разрядность генерируемой случайной величины
DAC_bit_res = 12 ## разрядность выходной случайной величины

m_tr     = int(2**DAC_bit_res/2 - 1) ## требуемое значение матожидания выходного процесса
print(m_tr)
sigma_tr = int(m_tr/3) ## требуемое значение СКО выходного процесса
print(sigma_tr)
result = [] ## массив отсчетов выходного процесса 

m_compens     = int((2**n - 1)/2 * N) ## матожидание чистого суммирования компонент случайного процесса 
print(m_compens)
sigma_compens = int(((2**n - 1)**2/12 * N)**(1/2)) ## матожидание чистого суммирования компонент случайного процесса 
print(sigma_compens)

norm_coef = int(sigma_tr * m_compens) ## вспомогательная величина для дальнейших вычислений 

m_calc = int((sigma_tr * m_compens)/sigma_compens - m_tr) ##  вспомогательная величина для дальнейших вычислений 
print(m_calc)

## пераметры конгруэнтной процедуры

m  = n 
l  = 31
z  = []
u  = 1

bit_deph = 36 ## разрядность случайной величины, моделируемой конгруэнтным генератором
z_curr = int(2**(m - 2) - 1) ## начальное значение для конгруэнтного генератора
print(z_curr)
result = [4095]

for i in range(130000-1): 
    
## непонятно почему, но это тоже работает :)

    # rnd = sum(np.random.randint(1, 2**n, size = N)) & (2**(N + n) - 1)
    # var = int(rnd - m_compens)
    # if var < 0:
    #     var = (2**(N + n + 5) - 1) - (-var-1)

    # rnd = (int(((var * sigma_tr)/sigma_compens) + m_tr)) & (2**N - 1)

##-----------------------------------------------------------------------------

    # rnd = sum(np.random.randint(1, 2**n, size = N)) & (2**(N + n) - 1)
    # var_1 = rnd * sigma_tr
    # var_2 = var_1 - norm_coef

    # if (var_2 < 0):
    #     var_2 = (2**(N + n) - 1) + (var_2 + 1)
    # rnd = (int((var_2)/sigma_compens + m_tr)) & (2**N - 1)

##-----------------------------------------------------------------------------

    # rnd = sum(np.random.randint(1, 2**n, size = N)) & (2**(N + n) - 1)

    # rnd = int((rnd * sigma_tr)/sigma_compens - m_calc) 

##-----------------------------------------------------------------------------


    for i in range(N):

        z_next = ((l * z_curr + u) & (2**bit_deph - 1))

        z.append(((z_next >> (bit_deph - m)) & (2**m - 1)))
        z_curr = z_next

    rnd = (sum(z) & (2**37 - 1))

    z = []

    var = int(rnd * sigma_tr)
    var = int(var/sigma_compens)

    rnd = int(var - m_calc) & (2**DAC_bit_res - 1)

    result.append(rnd)

# fig, (ax1, ax2) = plt.subplots(nrows = 2, ncols = 1)
# x = np.linspace(0, 4095, 4096)
# w = 1/(np.sqrt(2*np.pi) * sigma_tr) * np.exp(-(x - m_tr)**2/(2*sigma_tr**2))
# ax1.hist(result, bins = 100, density = True)
# ax1.grid()
# ax1.plot(x, w)

result = np.array(result)

result = result/(2**DAC_bit_res - 1) - 0.5

print(result[10000:10010])

acf = abs(np.correlate(result, result, 'full'))
acf /= acf.max()
acf = 10 * np.log10(acf)
plt.plot(acf)

plt.grid()

plt.show()