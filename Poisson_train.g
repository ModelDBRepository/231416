//Poisson_train.g
/* choose imax as you want, i.e. number of trains
   choose time length of trains as spike_length,
   note parameters of timetables, e.g. maxtime and mean interval, 
   now 10s and 'isi' s respectively */ 

int i0= 15000
int imin 
int imax= 100000
int loops=1+(imax-i0)/20
float spike_length= 1
str path1,tt
float isi,x1,x2,x3
int x4
int new_seed


int i, j, k
//include clock
setclock 0 10e-6
 
pushe /

create neutral /spikes
mkdir /home/kai/poissonTrains/{spike_length}"second"
/* create a set of noise spike trains */
for (k=1;k<=1;k=k+1)
mkdir /home/kai/poissonTrains/{spike_length}"second"/{k}

for (isi=1.; isi<=2.; isi=isi+0.1)
mkdir /home/kai/poissonTrains/{spike_length}"second"/{k}/"isi"{isi}
tt = { getarg {arglist {getdate}} -arg 4}  // using time for the random seeds
x1 = {substring {tt} 0 1}                  // hour;
x2 = {substring {tt} 3 4}                  // minute;
x3 = {substring {tt} 6 7}                  // second;
x4 = x1*x2*x3+ {pow {x1} 4} + {pow {x2} 4} + {pow {x3} 4}    // this formula is arbitrarily set to make a big but random number
new_seed = {rand 1 {x4}}
randseed {new_seed}
//This outer j loop is because can only have 20 files open at a time
for (j=1; j<loops; j=j+1) 
  imin=i0+j*20
  imax=imin+20
  for (i = {imin}; i < {imax}; i = i + 1)
    create timetable /spikes/tt_{i}
    setfield /spikes/tt_{i} maxtime {spike_length} method 1 act_val 1.0 meth_desc1 {isi} 
    call /spikes/tt_{i} TABFILL
    create event_tofile /spikes/tt_train_{i}
    setfield /spikes/tt_train_{i} threshold 1 fname "/home/kai/poissonTrains/"{spike_length}"second/"{k}"/isi"{isi}"/noise-isi"{isi}"-"{i} 
    addmsg /spikes/tt_{i} /spikes/tt_train_{i} INPUT activation
    call /spikes/tt_train_{i} RESET
  end

  check 
  reset

  step {spike_length} -t

echo "elements before deleting:"
le /spikes

  for (i = {imin}; i < {imax}; i = i + 1) 
    call /spikes/tt_train_{i} CLOSE
    delete /spikes/tt_train_{i}
    delete /spikes/tt_{i}
  end

echo "elements after deleting:"
le /spikes

end /* j loop */

end /* isi loop */

end /* k loop */

quit
