function parallel(i)
%     rang = ((i-1)*5+1):5*i;
    rang = 36:55;
    thr1 = (0.1:0.01:0.2)'; % 0 < . < 9.96
	thr2 = (1.25:0.75:7.25)'; % positive
	[thr1,thr2] = meshgrid(thr1,thr2);
	thrs = [thr1(:) thr2(:)];
    thrs = thrs(rang,:);

    tic
    fat = pfaT() %#ok<*NOPRT>
    fat.thrs = thrs
    fat.meth = inpM(fat)
    pfaI = fat.repe()

    mdt = pmdT()
    mdt.thrs = thrs
    mdt.meth = inpM(mdt)
    pmdI = mdt.repe()
    toc

    filename = sprintf('OCIpt%d.mat',i);
    save(filename)
end