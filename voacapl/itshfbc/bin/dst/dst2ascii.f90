program dst2ascii
    logical*1 file_exists
    real :: gcdkm, xlat, xlon, MUF, FOT, ANGLE, DELAY, VHITE, MUFday, LOSS
    real :: DBU, SDBW, NDBW, SNR, RPWRG, REL, MPROB, SPRB, SIGLW, SIGUP, SNRLW, SNRUP
    real :: TGAIN, RGAIN, SNRxx, DBM
    integer :: num_args
    character(len=128) :: itshfbc_path = ""
    integer :: ios
    integer :: NUMDIST, NUMFREQ, NUMHOUR
    real, dimension(1 : 25) :: FREQS
    integer, dimension(1 : 25) :: hours
    integer, parameter :: IDX_FILE = 70
    integer, parameter :: DST_FILE = 80
    integer, parameter :: ASC_FILE = 90
    integer :: HOURBLK
    integer :: ptr, utcPtr, freqPtr, offset, id = 0
    character(200) :: index_buffer
    character(4) :: xmode
    character(120) :: RUN_DIR
    character(len=1), parameter :: PATH_SEPARATOR ='/'
    character(len=128) :: idx_path, dst_path

    num_args = command_argument_count()
    
    if (num_args == 1) then
        call get_command_argument(1, itshfbc_path)
        idx_path = trim(itshfbc_path)//PATH_SEPARATOR//'run'//PATH_SEPARATOR//'voacapd.idx'
        dst_path = trim(itshfbc_path)//PATH_SEPARATOR//'run'//PATH_SEPARATOR//'voacapd.dst'
    else
        idx_path = 'voacapd.idx'
        dst_path = 'voacapd.dst'
    end if
    
    inquire(file=idx_path, exist=file_exists)
    if (.not.file_exists) then
        stop 'Unable to open IDX file '//idx_path
    end if

    inquire(file=dst_path, exist=file_exists)
    if (.not.file_exists) then
        stop 'Unable to open DST file '//idx_path
    end if

    open(IDX_FILE, file=idx_path, status='old')
    ! Read the number of distances
    read(IDX_FILE, '(I5A)') NUMDIST, index_buffer

    ! Read the frequencies
    read(IDX_FILE, '(I2A)') NUMFREQ, index_buffer
    do freqPtr = 1, NUMFREQ
        offset = 1 + (7*(freqPtr-1))
        read(index_buffer((offset): (offset+7)), '(F7.3)') FREQS(freqPtr)
    end do

    ! Read the hours
    read(IDX_FILE, '(I3A)') NUMHOUR, index_buffer
    do ptr = 1, NUMHOUR
        offset = 1 + (3*(ptr-1))
        read(index_buffer((offset): (offset+3)), '(I3)') hours(ptr)
    end do

    close(IDX_FILE)

    HOURBLK = NUMDIST * NUMFREQ

    open(DST_FILE,file=dst_path,status='old', form='unformatted',access='direct',recl=108)
    open(ASC_FILE,file='voacapd.asc')
    rewind(ASC_FILE)
    
    do utcPtr = 1, NUMHOUR
        write(ASC_FILE, '(AI2A)') "UTC:", utcPtr, ":00"
        do freqPtr = 1, 8
            write(ASC_FILE, '(AF6.3A)') "Freq:", freqs(freqPtr), "MHz"
            write(ASC_FILE, '(A3, A8, 2A10, A5, 23A8)') "id", "gcdkm", "Latitude", "Longitude", "Mode", &
                    "MUF", "FOT", "ANGLE", "DELAY", "VHITE", "MUFday", "LOSS", "DBU", "SDBW", "NDBW", "SNR", &
                    "RPWRG", "REL", "MPROB", "SPRB", "SIGLW", "SIGUP", "SNRLW", "SNRUP", "TGAIN", "RGAIN",  &
                    "SNRxx", "DBM"
            do ptr = NUMDIST-1, 0, -1
                read(DST_FILE, rec=((utcPtr-1)*HOURBLK)+(ptr*8)+freqPtr ) gcdkm,xlat,xlon,xmode, MUF, &
                    FOT, ANGLE, DELAY, VHITE, MUFday, LOSS, DBU, SDBW, &
                    NDBW, SNR, RPWRG, REL, MPROB, SPRB, SIGLW, SIGUP, &
                    SNRLW, SNRUP, TGAIN, RGAIN, SNRxx, DBM
                write(ASC_FILE, '(I3, F8.1, 2F10.4, A5, 23F8.3)') NUMDIST-ptr, gcdkm, xlat, xlon, xmode, MUF, FOT, ANGLE, &
                    DELAY, VHITE, MUFday, LOSS, DBU, SDBW, NDBW, SNR, RPWRG, REL, MPROB, SPRB, SIGLW, SIGUP, &
                    SNRLW, SNRUP, TGAIN, RGAIN, SNRxx, DBM
            end do
        end do
    end do
    close(DST_FILE)
    close(ASC_FILE)
end program dst2ascii