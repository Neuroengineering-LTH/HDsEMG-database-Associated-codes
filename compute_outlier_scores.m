data_dir = '';
subjects = 1:20;
channels = 1:128;

for subject=subjects
    load_path = [data_dir 's' num2str(subject) '.mat'];
    load(load_path)
    L = size(emg_extensors, 1);
    
    emg_flexors_flattened = reshape(permute(emg_flexors, [1 3 2]),[L 64]);
    emg_extensors_flattened = reshape(permute(emg_extensors, [1 3 2]), [L 64]);
    emg = [emg_flexors_flattened emg_extensors_flattened];
    
    p99s = zeros(size(channels));
    for c=channels
        signal = emg(:, c);
        p99 = prctile(signal, 99);
        p99s(c) = p99;
    end
    valid_channels = channels(find(mod(channels-1, 8)~=0));
    invalid_channels = channels(find(mod(channels-1, 8)==0));
    Q3 = prctile(p99s(valid_channels), 75);
    Q1 = prctile(p99s(valid_channels), 25);
    IQR = Q3 - Q1;
    thres = Q3 + 1.5*IQR;
    channel_outlier_score = max(p99s-thres, zeros(size(p99s))) ./ IQR;
    channel_outlier_score(invalid_channels) = 0;
    
    outlier_scores_flexors = channel_outlier_score(1:64);
    outlier_scores_flexors = reshape(outlier_scores_flexors, [8, 8])';
    
    outlier_scores_extensors = channel_outlier_score(65:128);
    outlier_scores_extensors = reshape(outlier_scores_extensors, [8, 8])';

    save(load_path, 'outlier_scores_flexors', 'outlier_scores_extensors', '-append');
end