import tensorflow as tf

# Linear Regression
import numpy as np
num_points = 1000
vector_set = []

for i in xrange(num_points):
    x1 = np.random.normal(0.0, 0.55)
    y1 = x1 * 0.1 + 0.3 + np.random.normal(0.0, 0.03)

    vector_set.append([x1, y1])

x_data = [v[0] for v in vector_set]
y_data = [v[1] for v in vector_set]

import matplotlib.pyplot as plt

W = tf.Variable(tf.random_uniform([1], -1.0, 1.0))
b = tf.Variable(tf.zeros([1]))

y = W * x_data + b

loss = tf.reduce_mean(tf.square(y - y_data))

# Gradient Descent
optimizer = tf.train.GradientDescentOptimizer(0.5)
train = optimizer.minimize(loss)

# Run
init = tf.initialize_all_variables()

sess = tf.Session()
sess.run(init)

for step in xrange(40):
    sess.run(train)
    print sess.run(loss)
    print step, sess.run(W), sess.run(b)

plt.plot(x_data, y_data, 'ro')
plt.plot(x_data, sess.run(W) * x_data + sess.run(b))
plt.legend()
plt.show()
