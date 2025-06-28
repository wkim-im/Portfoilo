import numpy as np

x1 = np.arange(0, 16).reshape(16, 1)
x2 = np.arange(15,-1,-1).reshape(16,1)
weight = np.array([
    [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15 ],
    [15,14,13,12,11,10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0 ],
    [ 2, 4, 6, 8,10,12,14, 2, 4, 6, 8,10,12,14, 2, 4 ],
    [ 1, 3, 5, 7, 9,11,13,15, 1, 3, 5, 7, 9,11,13,15 ]
])

y1 = np.matmul(weight, x1)
y2 = np.matmul(weight, x2)

print("x1 (입력):\n", x1)
print("\nweight (가중치):\n", weight)
print("\ny1 = weight * x1 결과:\n", y1)

result1 = y1[0]+y1[1]+y1[2]+y1[3]
print("\nresult1 = y1행 합 결과 :\n",result1)

print("x2 (입력):\n", x2)
print("\ny2 = weight * x2 결과:\n", y2)

result2 = y2[0]+y2[1]+y2[2]+y2[3]
print("\nresult = y2행 합 결과 :\n",result2)
