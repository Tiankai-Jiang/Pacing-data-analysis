import tensorflow as tf
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

np.random.seed(0)
# 创建占位符
X = tf.placeholder(tf.float32, [None, 37])
Y = tf.placeholder(tf.float32, [None, 5])

# 创建变量
# tf.random_normal([1])返回一个符合正太分布的随机数
w = tf.Variable(tf.zeros([37, 5], name='weight'))
b = tf.Variable(tf.zeros([5], name='bias'))

y_predict = tf.sigmoid(tf.add(tf.matmul(X, w), b))
num_samples = 400
cost = tf.reduce_sum(tf.pow(y_predict - Y, 2.0)) / num_samples
# cost = tf.reduce_mean(-tf.reduce_sum(Y*tf.log(y_predict), reduction_indices=1))


# 学习率
lr = 0.1
optimizer = tf.train.AdamOptimizer().minimize(cost)

# 创建session 并初始化所有变量
num_epoch = 15000
cost_accum = []
cost_prev = 0

dataframe = pd.read_csv('full-data.csv', sep=',')
dataframe = dataframe.reindex(np.random.permutation(dataframe.index))
onehot_mode = pd.get_dummies(dataframe['mode'])
onehot_list = onehot_mode.columns.values.tolist()
onehot_dict = {}
for i in range(len(onehot_list)):
    onehot_dict[i] = onehot_list[i]

xs = dataframe.head(75)[
    ['T101', 'T102', 'T103', 'T104', 'T105', 'T106', 'T107', 'T108', 'T109', 'T110', 'T111', 'T112', 'T113', 'T114',
     'T115', 'T116', 'T117', 'T118', 'T119', 'T120', 'T121', 'T122', 'T123', 'T124', 'T201', 'T202', 'T203', 'T204',
     'T205', 'T206', 'T207', 'T208', 'T209', 'T210', 'T211', 'T212', 'T301']].values

ys = onehot_mode.head(75).values

test_xs = dataframe.tail(23)[
    ['T101', 'T102', 'T103', 'T104', 'T105', 'T106', 'T107', 'T108', 'T109', 'T110', 'T111', 'T112', 'T113', 'T114',
     'T115', 'T116', 'T117', 'T118', 'T119', 'T120', 'T121', 'T122', 'T123', 'T124', 'T201', 'T202', 'T203', 'T204',
     'T205', 'T206', 'T207', 'T208', 'T209', 'T210', 'T211', 'T212', 'T301']].values
tys = onehot_mode.tail(23).values

with tf.Session() as sess:
    # 初始化所有变量
    sess.run(tf.initialize_all_variables())
    # 开始训练
    for epoch in range(num_epoch):
        # for x, y in zip(xs, ys):
        train_cost = sess.run(cost, feed_dict={X: xs, Y: ys})
        sess.run(optimizer, feed_dict={X: xs, Y: ys})
        cost_accum.append(train_cost)

        # 当误差小于10-6时 终止训练
        # if np.abs(cost_prev - train_cost) < 1e-6:
        #     break
        # 保存最终的误差
        cost_prev = train_cost
    # 画图  画出每一轮训练所有样本之后的误差
    print("train_cost is:", str(cost_prev))
    plt.plot(range(len(cost_accum)), cost_accum, 'r')
    plt.title('Logic Regression Cost Curve')
    plt.xlabel('epoch')
    plt.ylabel('cost')
    plt.show()

    # plt.plot(xs, np.ones(len(xs)), '.')
    pred_train_y = sess.run(y_predict, feed_dict={X: xs})
    # plt.plot(xs, [i[0] for i in pred_y], '.')
    # plt.show()
    print(pred_train_y)
    oo_y = tf.arg_max(Y, 1)
    oo_y_pred = tf.arg_max(y_predict, 1)
    correct_prediction = tf.equal(oo_y, oo_y_pred)
    accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))
    print('训练集正确率：%f' % sess.run(accuracy, feed_dict={X: xs, Y: ys}))
    print('测试集正确率：%f' % sess.run(accuracy, feed_dict={X: test_xs, Y: tys}))
    y_list = sess.run(oo_y, feed_dict={X: test_xs, Y: tys})
    y_pred_list = sess.run(oo_y_pred, feed_dict={X: test_xs, Y: tys})
    print('real\t\tpred')
    for i in range(len(y_list)):
        print('%s\t\t%s' % (onehot_dict[y_list[i]], onehot_dict[y_pred_list[i]]))
    # count = 0
    # for i in range(75):
    #     if (train_ys[i] == 0):
    #         if pred_train_y[i][0][0] > 0.5:
    #             count += 1
    #     if (train_ys[i] == 1):
    #         if pred_train_y[i][0][0] < 0.5:
    #             count += 1
    #
    # print('训练集正确率%f' % (count / 75.0))
    #
    # # plt.plot(xs, np.ones(len(xs)), '.')
    # pred_y = sess.run(y_predict, feed_dict={X: [[temp] for temp in test_xs]})
    # # plt.plot(xs, [i[0] for i in pred_y], '.')
    # # plt.show()
    # print(pred_y)
    # count = 0
    # for i in range(23):
    #     if (test_ys[i] == 0):
    #         if pred_y[i][0][0] > 0.5:
    #             count += 1
    #             print('是0，猜对了')
    #         else:
    #             print('是0，猜错了')
    #     if (test_ys[i] == 1):
    #         if pred_y[i][0][0] < 0.5:
    #             count += 1
    #             print('是1，猜对了')
    #         else:
    #             print('是1，猜错了')
    # print('测试集正确率%f' % (count / 23.0))
