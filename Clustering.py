# -*- coding: utf-8 -*-

# Author: Yixuan Xu
# Latest Updated Time: 26 Mar, 2017

from __future__ import absolute_import
from __future__ import unicode_literals
from __future__ import division
from __future__ import absolute_import

import numpy as np
import scipy.io as scio
from sklearn.cluster import KMeans, MeanShift, estimate_bandwidth

if __name__ == '__main__':
    
    # load data
    DataSource_Path = 'D://X.mat'
    Data = scio.loadmat(DataSource_Path)
    Data = np.array(Data['X'],dtype = 'int')
    
    # traditional kmeans
    model = KMeans(n_clusters=50, init='random', max_iter=500)
    
    # kmeans++ 
    model = KMeans(n_clusters=50, init='random', max_iter=500)
    
    # mean-shift
    bandwidth = estimate_bandwidth(Data, quantile=0.02, n_samples=10000)
    model = MeanShift(bandwidth=bandwidth, bin_seeding=True)
    
    model.fit(Data)
    
    label = model.labels_
    centroid = model.cluster_centers_
    data = {}
    data['centroid'] = centroid
    data['label'] = label

    scio.savemat('Clustering_Result.mat',data)
