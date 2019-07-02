function pre_build {
    build_swig
    build_openblas
}

function pip_wheel_cmd {
    local abs_wheelhouse=$1
    local np_include=$(python -c "import numpy as np; print(np.get_include())")

    if [ -n "$IS_OSX" ]; then
        local with_blas="-lopenblas -L/usr/local/opt/openblas/lib"
    else
        local with_blas="-pthread -lgfortran -static-libgfortran -l:libopenblas.a"
    fi

    (./configure \
        --without-cuda \
        --with-blas="$with_blas" \
        CFLAGS="-I$np_include $CFLAGS" \
        && make -j4 \
        && make -C python \
        && cd python \
        && pip wheel $(pip_opts) -w $abs_wheelhouse --no-deps .)
}

function run_tests {
    if [ ! -n "$IS_OSX" ]; then
        apt-get update \
            && apt-get install -y libgfortran3 \
            && rm -rf /var/lib/apt/lists/*
    fi
    python --version
    python -c "import faiss"
}
