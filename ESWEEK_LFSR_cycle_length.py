#!/usr/bin/env python
# coding: utf-8

# In[12]:


get_ipython().system('conda install sympy -y')


# In[ ]:


import random
from sympy import symbols, Poly, GF
from multiprocessing import Pool, cpu_count

def generate_random_taps(N):
    base_taps = [N, 1]
    possible = list(range(2, N))
    num_extra = random.randint(0, len(possible))
    random.shuffle(possible)
    taps = base_taps + possible[:num_extra]
    return sorted(set(taps), reverse=True)

def is_primitive_poly(tap_points):
    x = symbols('x')
    expr = sum([x**(t - 1) for t in tap_points]) + 1
    poly = Poly(expr, x, domain=GF(2))
    return poly.is_irreducible

def lfsr_next_state(state, taps_mask, width):
    feedback = 0
    for i in range(width):
        if (taps_mask >> i) & 1:
            feedback ^= (state >> i) & 1
    return ((state << 1) | feedback) & ((1 << width) - 1)

def lfsr_cycle_length_floyd(tap_bits, width):
    taps_mask = sum(1 << (width - t) for t in tap_bits)
    seed = random.randint(1, (1 << width) - 1)

    tortoise = lfsr_next_state(seed, taps_mask, width)
    hare = lfsr_next_state(lfsr_next_state(seed, taps_mask, width), taps_mask, width)

    while tortoise != hare:
        tortoise = lfsr_next_state(tortoise, taps_mask, width)
        hare = lfsr_next_state(lfsr_next_state(hare, taps_mask, width), taps_mask, width)

    lam = 1
    hare = lfsr_next_state(tortoise, taps_mask, width)
    while tortoise != hare:
        hare = lfsr_next_state(hare, taps_mask, width)
        lam += 1

    return lam

def run_single_experiment(N, _):
    tap_points = generate_random_taps(N)
    print(tap_points)
    if is_primitive_poly(tap_points):
        return (1 << N) - 1
    else:
        return lfsr_cycle_length_floyd(tap_points, N)

# 🔧 Main entry
if __name__ == "__main__":
    import time
    from multiprocessing import set_start_method
    set_start_method("fork", force=True)

    N = int(input("Enter LFSR size in bits (e.g. 48): "))
    K = int(input("Enter number of experiments: "))

    print(f"Running on {min(cpu_count(), K)} CPU cores...")

    start = time.time()
    with Pool(processes=min(cpu_count(), K)) as pool:
        # Each task is (N, experiment_number)
        args = [(N, i) for i in range(K)]
        results = pool.starmap(run_single_experiment, args)

    end = time.time()

    print(f"\nLFSR size: {N}-bit")
    print(f"Experiments: {K}")
    print(f"Average cycle length: {sum(results) / K:.2f}")
    print(f"Minimum cycle length: {min(results)}")
    print(f"Maximum cycle length: {max(results)}")
    print(f"Total time: {end - start:.2f} seconds")

