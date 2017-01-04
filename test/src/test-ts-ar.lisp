
(in-package :clml.test)

(define-test test-sample-ts-ar
    (let (model traffic pred std-err ukgas)
      (assert
       (setq ukgas
           (time-series-data (read-data-from-file (clml.utility.data:fetch "https://mmaul.github.io/clml.data/sample/UKgas.sexp"))
                             :range '(1) :time-label 0
                             :start 1960 :frequency 4)))
      (assert (setq model (ar ukgas)))
      (with-accessors ((coefs clml.time-series.autoregression::ar-coefficients)
                       (s2 clml.time-series.autoregression::sigma^2)
                       (dem clml.time-series.autoregression::demean)
                       (method clml.time-series.autoregression::ar-method)) model
        (assert-equality #'epsilon> 337.63055555555553d0 (aref dem 0))
        (assert-equality #'epsilon> 1231.505368951319d0 s2)
        (assert-eq :burg method)
        (assert-eql 9 (car coefs))
        (assert-true
         (set-equal
          '(0.17438913366790465d0 -0.20966263354643136d0 0.459202505071864d0 1.0144694385486095d0
            0.2871426375860843d0 -0.09273505423571009d0 -0.13087574744684466d0
            -0.34467398543738703d0 -0.1765456124104221d0)
          (nth (car coefs) (cdr coefs)) :test #'epsilon>))
        (assert-true
         (set-equal
          '(1501.2718014157313d0 1460.9668773820204d0 1456.8083062004769d0 1173.9212517211515d0
            1118.7755607938218d0 1118.3837442819588d0 1115.6105115537998d0 1112.0135795536412d0
            1096.4376790206923d0 1095.0179215136407d0 1096.909318127515d0 1097.1527749424165d0
            1095.5232071332118d0 1097.5230807182193d0 1099.3876611523242d0 1101.3189817751283d0
            1099.1548231232998d0 1101.0027662762807d0 1098.8203207533102d0 1099.7222047541711d0
            1099.8811865464495d0)
          (slot-value model 'clml.time-series.autoregression::aic)
          :test #'epsilon>)))
      (assert
       (multiple-value-setq (pred std-err) (predict model :n-ahead 12)))
      (assert-true
       (set-equal
        '(1158.968335237735d0 674.0825414839333d0 366.47039894800133d0 824.7744606535753d0
          1130.8933680605721d0 680.8529858555869d0 394.30291696412894d0 848.437536065712d0
          1108.662583735234d0 657.0657782567591d0 415.63194106293474d0 864.145487186373d0)
        (map 'list (lambda (p) (aref (ts-p-pos p) 0)) (subseq (ts-points pred) 99))
        :test #'epsilon>))
      (assert-true
       (set-equal
        '(24.072473467386356d0 24.435772883017183d0 24.813834116264307d0 26.54224594057747d0
          39.23623299465764d0 41.10506405187747d0 41.40800174746806d0 43.90893251815273d0
          54.80459423968943d0 56.842223276645484d0 56.887059327654924d0 59.51296740330941d0)
        (map 'list (lambda (p) (aref (ts-p-pos p) 0)) (subseq (ts-points std-err) 99))
        :test #'epsilon>))

      (assert (setq pred (ar-prediction ukgas :method :burg :n-learning 80 :n-ahead 12)))
      (assert-true
       (set-equal
        '(130.45676936346104d0 87.60635293229583d0 122.88786839248075d0 178.94011319531705d0
          156.84147856236507d0 102.84671815160169d0 137.22718174882334d0 196.06745641722725d0
          161.21300979672128d0 98.3371415342315d0 122.99204535051106d0 174.9135542815775d0
          149.70895559933712d0 96.7868200434138d0 129.32910153233206d0 194.21488504375918d0
          169.54177278845833d0 111.30821687507844d0 145.84465159828247d0 209.25523557065864d0
          176.77307718994325d0 110.91256767754314d0 143.671869822806d0 212.60072940284869d0
          190.8578749155616d0 123.93020161509278d0 155.54330830254918d0 239.89854515283696d0
          216.72941697369188d0 125.11455006254147d0 152.75047833157052d0 254.14811430124462d0
          231.70704604033028d0 134.68070689972973d0 161.81292087728184d0 238.91528022110714d0
          253.2222429543477d0 185.87018645634888d0 210.89898806663751d0 283.15953150552724d0
          212.60286183923515d0 139.66772357972337d0 289.11042995402096d0 379.67218660230697d0
          236.50652119281568d0 201.0619705811411d0 355.93211320870216d0 427.7709499062007d0
          251.41311492438817d0 175.84075174003493d0 366.3184242605247d0 495.6053510355538d0
          324.3544105320806d0 221.16451064723796d0 413.05915853853116d0 537.1910215888053d0
          335.73421818847015d0 190.69328343758573d0 426.06969221031795d0 618.8957022203703d0
          363.64762691517967d0 204.57366609682452d0 468.75299627703237d0 636.837238061131d0
          390.04827140667186d0 229.81062187790073d0 476.49786499318043d0 702.6752280625772d0
          457.3451187497445d0 225.10505626834149d0 558.3402024714769d0 865.3941458174183d0
          546.1735039882099d0 216.99532367966316d0 533.191980857029d0 857.3576423231889d0
          570.7906320723246d0 244.96877465994973d0 508.7073952630259d0 845.7343372322819d0
          588.6667393873022d0 252.30662988389d0 486.787425955227d0 814.0313284232438d0)
        (map 'list (lambda (p) (aref (ts-p-pos p) 0)) (ts-points pred))
        :test #'epsilon>))

      (assert
       (setq traffic (time-series-data
                      (read-data-from-file (clml.utility.data:fetch "https://mmaul.github.io/clml.data/sample/mawi-traffic/pointF-20090330-0402.sexp"))
                      :except '(0) :time-label 0)))
      (assert-true (parcor-filtering traffic :ppm-fname "traffic.ppm"))))
