/**
 * @file MLMatrix+Advanced.m
 * @author Krisna Pranav
 * @version 1.0
 * @date 2025-05-03
 *
 * @copyright Copyright (c) 2025 Krisna Pranav
 *
 */

#import "Matrix+Advanced.h"
#import "Constants.h"
#import "HaltonInterface.h"

static double boxMuller();
static void SVDColumnMajor(double *A, __CLPK_integer rows, __CLPK_integer columns,
                           double **s, double **u, double **vt);
static void pInv(double *A, int rows, int columns, double *Aplus);
static void MEVV(double *A, int m, int n, double *vr, double *vi, double *vecL, double *vecR);

typedef struct nlopt_soboldata_s {
    unsigned sdim;
    uint32_t *mdata;
    uint32_t *m[32];
    uint32_t *x;
    unsigned *b;
    uint32_t n;
} soboldata;

typedef struct nlopt_soboldata_s *nlopt_sobol;

static int sobol_init(soboldata *sd, unsigned sdim);
static int sobol_gen(soboldata *sd, double *x);
static void sobol_destroy(soboldata *sd);


@implementation Matrix (Advanced)

+ (instancetype)uniformRandomLowerBound:(Matrix *)lower upperBound:(Matrix *)upper
{
    NSAssert (lower.rows == upper.rows && lower.columns == upper.columns, @"Matrix size mismatch");

    Matrix *result = [lower copy];
    Matrix *range = [upper matrixBySubtracting:lower];

    for (int i=0, j=(int)[result count]; i<j; i++)
    {
        result->matrix[i] += ((double)arc4random() / ARC4RANDOM_MAX) * range->matrix[i];
    }
    return result;
}

+ (instancetype)uniformRandomRows:(int)rows columns:(int)columns domain:(YCDomain)domain
{
    Matrix *result = [Matrix matrixOfRows:rows columns:columns];
    for (int i=0, j=(int)[result count]; i<j; i++)
    {
        result->matrix[i] = ((double)arc4random() / ARC4RANDOM_MAX) * domain.length + domain.location;
    }
    return result;
}

+ (instancetype)uniformRandomLowerBound:(Matrix *)lower upperBound:(Matrix *)upper count:(int)count
{
    NSAssert ((lower.rows == upper.rows && lower.columns == upper.columns == 1) ||
              (lower.columns == upper.columns && lower.rows == upper.rows == 1),
              @"Matrix size mismatch");

    if (lower.rows == 1)
    {
        Matrix *result = [Matrix matrixOfRows:count columns:lower.columns];
        Matrix *range = [upper matrixBySubtracting:lower];

        for (int i=0, k=(int)result.rows; i<k; i++)
        {
            for (int j=0, l=(int)result.columns; j<l; j++)
            {
                result->matrix[i*l + j] = lower->matrix[j] +
                    ((double)arc4random() / ARC4RANDOM_MAX) * range->matrix[j];
            }
        }
        return result;
    }
    else
    {
        Matrix *result = [Matrix matrixOfRows:lower.rows columns:count];
        Matrix *range = [upper matrixBySubtracting:lower];

        for (int i=0, k=(int)result.rows; i<k; i++)
        {
            for (int j=0, l=(int)result.columns; j<l; j++)
            {
                result->matrix[i*l + j] = lower->matrix[i] +
                    ((double)arc4random() / ARC4RANDOM_MAX) * range->matrix[i];
            }
        }
        return result;
    }
}

+ (instancetype)normalRandomMean:(Matrix *)mean variance:(Matrix *)variance
{
    NSAssert(mean.rows == variance.rows && mean.columns == variance.columns, @"Matrix size mismatch");
    Matrix *result = [Matrix matrixLike:mean];

    for (int i=0, j=(int)mean.count; i<j; i++)
    {
        result->matrix[i] = mean->matrix[i] + sqrt(variance->matrix[i]) * boxMuller();
    }
    return result;
}

+ (instancetype)normalRandomRows:(int)rows
                           columns:(int)columns
                              mean:(double)mean
                          variance:(double)variance
{
    Matrix *result = [Matrix matrixOfRows:rows columns:columns];
    double sigma = sqrt(variance);

    for (int i=0, j=(int)[result count]; i<j; i++)
    {
        result->matrix[i] = mean + sigma * boxMuller();
    }
    return result;
}

+ (instancetype)normalRandomMean:(Matrix *)mean variance:(Matrix *)variance count:(int)count
{
    NSAssert ((mean.rows == variance.rows && mean.columns == variance.columns == 1) ||
              (mean.columns == variance.columns && mean.rows == variance.rows == 1),
              @"Matrix size mismatch");

    if (mean.rows == 1)
    {
        Matrix *result = [Matrix matrixOfRows:count columns:mean.columns];

        for (int i=0, k=(int)result.rows; i<k; i++)
        {
            for (int j=0, l=(int)result.columns; j<l; j++)
            {
                result->matrix[i*l + j] = mean->matrix[j] + sqrt(variance->matrix[j]) * boxMuller();
            }
        }
        return result;
    }
    else
    {
        Matrix *result = [Matrix matrixOfRows:mean.rows columns:count];

        for (int i=0, k=(int)result.rows; i<k; i++)
        {
            double sigma = sqrt(variance->matrix[i]);
            for (int j=0, l=(int)result.columns; j<l; j++)
            {
                result->matrix[i*l + j] = mean->matrix[i] + sigma * boxMuller();
            }
        }
        return result;
    }
}

+ (instancetype)sobolSequenceLowerBound:(Matrix *)lower
                             upperBound:(Matrix *)upper
                                  count:(int)count;
{
    NSAssert (lower.rows == upper.rows && 1 == lower.columns && 1 == upper.columns,
              @"Matrix size mismatch");

    Matrix *result = [Matrix matrixOfRows:lower.rows columns:count];
    Matrix *range = [upper matrixBySubtracting:lower];

    int sdim = result.rows;
    int n = result.columns;
    nlopt_sobol s = (nlopt_sobol) malloc(sizeof(soboldata));
    if (!s) return nil;
    if (!sobol_init(s, sdim))
    {
        free(s);
        return nil;
    }

    double x[sdim];

    if (s) {
        unsigned k = 1;
        while (k*2 < n) k *= 2;
        while (k-- > 0) sobol_gen(s, x);
    }

    for (int j = 1; j <= n; ++j)
    {
        if (!sobol_gen(s, x)) {
            unsigned i;
            for (i = 0; i < s->sdim; ++i)
                x[i] = ((double)arc4random() / ARC4RANDOM_MAX);
        }

        for (int i = 0; i < s->sdim; ++i)
        {
            result->matrix[i * n + j] = lower->matrix[i] + x[i] * range->matrix[i];
        }
    }
    if (s) {
        sobol_destroy(s);
        free(s);
    }

    return result;
}

+ (instancetype)haltonSequenceWithLowerBound:(Matrix *)lower
                                  upperBound:(Matrix *)upper
                                       count:(int)count
{
    NSAssert (lower.rows == upper.rows && 1 == lower.columns && 1 == upper.columns,
              @"Matrix size mismatch");

    Matrix *result = [HaltonInterface sampleWithDimension:lower.rows count:count];

    [result multiplyColumn:upper];
    [result addColumn:lower];

    return result;
}

- (Matrix *)pseudoInverse
{
    Matrix *ret = [Matrix matrixOfRows:self->columns columns:self->rows];

    pInv(self->matrix, self->rows, self->columns, ret->matrix);
    return ret;
}

- (NSDictionary *)SVD
{
    double *ua = NULL;
    double *sa = NULL;
    double *va = NULL;

    SVDColumnMajor([self matrixByTransposing]->matrix, (__CLPK_integer)rows, (__CLPK_integer)columns, &sa, &ua, &va);

    Matrix *U = [[Matrix matrixFromArray:ua rows:self->columns columns:self->rows mode:YCMWeak] matrixByTransposing]; // mxm
    Matrix *S = [Matrix matrixOfRows:self->columns columns:self->columns valuesInDiagonal:sa value:0]; // mxn
    Matrix *V = [Matrix matrixFromArray:va rows:self->columns columns:self->columns mode:YCMWeak]; // nxn

    return @{@"U" : U, @"S" : S, @"V" : V};
}

- (Matrix *)solve:(Matrix *)B
{
    NSAssert(columns == rows, @"Matrix not square");
    Matrix *bTranspose = B;
    if (B->columns > 1)
    {
        bTranspose = [B matrixByTransposing];
    }
    Matrix *aTranspose = [self matrixByTransposing];

    __CLPK_integer n = self->rows;
    __CLPK_integer nrhs = B->columns;
    __CLPK_integer lda = self->rows;
    __CLPK_integer ldb = self->rows;

    __CLPK_integer ipiv[n];

    __CLPK_integer info = 0;

    dgesv_(&n, &nrhs, aTranspose->matrix, &lda, ipiv, bTranspose->matrix, &ldb, &info);

    NSAssert (info <= 0, @"Matrix U is singular.");
    NSAssert (info >= 0, @"Error solving linear system A*X=B.");

    if (B->columns > 1)
    {
        return [bTranspose matrixByTransposing];
    }
    return bTranspose;
}

- (void)cholesky
{
    char uplo = 'U';
    __CLPK_integer rank = self->rows;
    __CLPK_integer info;
    __CLPK_integer i,j;

    dpotrf_(&uplo, &rank, self->matrix, (__CLPK_integer *)&self->rows, &info);

    if(info > 0)
    {
        @throw [NSException exceptionWithName:@"YCMatrixException"
                                       reason:@"Matrix is not positive definite."
                                     userInfo:nil];
    }

    for(i=0; i<self->rows; i++)
    {
        for(j=i+1; j<self->columns; j++)
        {
            self->matrix[i*self->columns + j] = 0.0;
        }
    }
}

- (Matrix *)matrixByCholesky
{
    Matrix *newMatrix = [self copy];
    [newMatrix cholesky];
    return newMatrix;
}

- (Matrix *)realEigenvalues
{
    NSAssert(columns == rows, @"Matrix not square");
    double *evArray = malloc(self->rows * sizeof(double));

    MEVV(self->matrix, self->rows, self->columns, evArray, nil, nil, nil);

    return [Matrix matrixFromArray:evArray rows:1 columns:self->columns];
}

- (NSDictionary *)eigenvectorsAndEigenvalues
{
    NSAssert(columns == rows, @"Matrix not square");
    int m = self->rows;
    double *revArray = malloc(m * sizeof(double));
    double *ievArray = malloc(m * sizeof(double));
    double *leVecArray = malloc(m * m * sizeof(double));
    double *reVecArray = malloc(m * m * sizeof(double));

    MEVV(self->matrix, m, m, revArray, ievArray, leVecArray, reVecArray);

    Matrix *revMatrix = [Matrix matrixFromArray:revArray rows:1 columns:m];
    Matrix *ievMatrix = [Matrix matrixFromArray:ievArray rows:1 columns:m];

    Matrix *leVecMatrix = [[Matrix matrixFromArray:reVecArray rows:m columns:m] matrixByTransposing];
    Matrix *reVecMatrix = [[Matrix matrixFromArray:leVecArray rows:m columns:m] matrixByTransposing];
    return @{@"Real Eigenvalues":revMatrix,
             @"Imaginary Eigenvalues":ievMatrix,
             @"Left Eigenvectors":leVecMatrix,
             @"Right Eigenvectors":reVecMatrix};
}

- (double)determinant
{
    __CLPK_integer info;
    double det = 1.0;
    __CLPK_integer neg = 0;

    NSAssert(columns == rows, @"Matrix not square");

    __CLPK_integer m = self->rows;
    __CLPK_integer length = m*m;

    double *A = malloc(length * sizeof(double));
    memcpy(A, self->matrix, length * sizeof(double));

    __CLPK_integer *ipvt = malloc(m * sizeof(int));

    dgetrf_(&m, &m, A, &m, ipvt, &info);

    if(info > 0) {
        free(ipvt);
        free(A);
        return 0.0;
    }

    for (int c1 = 0; c1 < m; c1++) {
        double c = A[c1 + m*c1];
        det *= c;
        if (ipvt[c1] != (c1+1)) neg = !neg;
    }

    free(ipvt);
    free(A);

    return neg?-det:det;
}

- (Matrix *)sumsOfRows
{
    Matrix *result = [Matrix matrixOfRows:self.rows columns:1];
    for (int i=0; i<self.rows; i++)
    {
        double sum = 0;
        for (int j=0; j<self.columns; j++)
        {
            sum += self->matrix[i*self.columns + j];
        }
        result->matrix[i] = sum;
    }
    return result;
}

- (Matrix *)sumsOfColumns
{
    Matrix *result = [Matrix matrixOfRows:1 columns:self.columns];
    for (int i=0; i<self.columns; i++)
    {
        double sum = 0;
        for (int j=0; j<self.rows; j++)
        {
            sum += self->matrix[j*self.columns + i];
        }
        result->matrix[i] = sum;
    }
    return result;
}

- (Matrix *)meansOfRows
{
    Matrix *means = [Matrix matrixOfRows:self.rows columns:1];
    for (int i=0; i<rows; i++)
    {
        double rowMean = 0;
        for (int j=0; j<columns; j++)
        {
            rowMean += matrix[i*self.columns + j];
        }
        rowMean /= columns;
        means->matrix[i] = rowMean;
    }
    return means;
}

- (Matrix *)meansOfColumns
{
    Matrix *means = [Matrix matrixOfRows:1 columns:self.columns];
    for (int i=0; i<columns; i++)
    {
        double columnMean = 0;
        for (int j=0; j<rows; j++)
        {
            columnMean += matrix[j*self.columns + i];
        }
        columnMean /= rows;
        means->matrix[i] = columnMean;
    }
    return means;
}

- (Matrix *)variancesOfRows
{
    Matrix *means = [self meansOfRows];
    Matrix *d2 = [self matrixBySubtractingColumn:means];
    [d2 elementWiseMultiply:d2];
    Matrix *sums = [d2 sumsOfRows];
    [sums multiplyWithScalar:1.0/self.columns];
    return sums;
}

- (Matrix *)variancesOfColumns
{
    Matrix *means = [self meansOfColumns];
    Matrix *d2 = [self matrixBySubtractingRow:means];
    [d2 elementWiseMultiply:d2];
    Matrix *sums = [d2 sumsOfColumns];
    [sums multiplyWithScalar:1.0/self.rows];
    return sums;
}

- (Matrix *)sampleVariancesOfRows
{
    Matrix *means = [self meansOfRows];
    Matrix *d2 = [self matrixBySubtractingColumn:means];
    [d2 elementWiseMultiply:d2];
    Matrix *sums = [d2 sumsOfRows];
    [sums multiplyWithScalar:1.0/(self.columns - 1)];
    return sums;
}

- (Matrix *)sampleVariancesOfColumns
{
    Matrix *means = [self meansOfColumns];
    Matrix *d2 = [self matrixBySubtractingRow:means];
    [d2 elementWiseMultiply:d2];
    Matrix *sums = [d2 sumsOfColumns];
    [sums multiplyWithScalar:1.0/(self.rows - 1)];
    return sums;
}

- (Matrix *)minimumsOfRows
{
    Matrix *mins = [Matrix matrixOfRows:self.rows columns:1];
    for (int i=0; i<rows; i++)
    {
        double rowMin = DBL_MAX;
        double temp;
        for (int j=0; j<columns; j++)
        {
            temp = matrix[i*self.columns + j];
            if (temp < rowMin) rowMin = temp;
        }
        mins->matrix[i] = rowMin;
    }
    return mins;
}

- (Matrix *)maximumsOfRows
{
    Matrix *maxs = [Matrix matrixOfRows:self.rows columns:1];
    for (int i=0; i<rows; i++)
    {
        double rowMax = -DBL_MAX;
        double temp;
        for (int j=0; j<columns; j++)
        {
            temp = matrix[i*self.columns + j];
            if (temp > rowMax) rowMax = temp;
        }
        maxs->matrix[i] = rowMax;
    }
    return maxs;
}

- (Matrix *)minimumsOfColumns
{
    Matrix *mins = [Matrix matrixOfRows:1 columns:self.columns];
    for (int i=0; i<columns; i++)
    {
        double columnMin = DBL_MAX;
        double temp;
        for (int j=0; j<rows; j++)
        {
            temp = matrix[j*self.columns + i];
            if (temp < columnMin) columnMin = temp;
        }
        mins->matrix[i] = columnMin;
    }
    return mins;
}

- (Matrix *)maximumsOfColumns
{
    Matrix *maxs = [Matrix matrixOfRows:1 columns:self.columns];
    for (int i=0; i<columns; i++)
    {
        double columnMax = -DBL_MAX;
        double temp;
        for (int j=0; j<rows; j++)
        {
            temp = matrix[j*self.columns + i];
            if (temp > columnMax) columnMax = temp;
        }
        maxs->matrix[i] = columnMax;
    }
    return maxs;
}

- (Matrix *)matrixByApplyingFunction:(double (^)(double value))function
{
    Matrix *newMatrix = [self copy];
    [newMatrix applyFunction:function];
    return newMatrix;
}

- (void)applyFunction:(double (^)(double value))function
{
    NSUInteger count = [self count];
    for (int i=0; i<count; i++)
    {
        self->matrix[i] = function(self->matrix[i]);
    }
}

- (double)euclideanDistanceTo:(Matrix *)other
{
    return sqrt([self quadranceTo:other]);
}

- (double)quadranceTo:(Matrix *)other
{
    Matrix *result = [self matrixBySubtracting:other];
    [result elementWiseMultiply:result];
    return [result sum];
}

- (void)bernoulli
{
    NSUInteger count = self.count;
    for (int i=0; i<count; i++)
    {
        if (self->matrix[i] > ((double)arc4random() / ARC4RANDOM_MAX))
        {
            self->matrix[i] = 1;
        }
        else
        {
            self->matrix[i] = 0;
        }
    }
}

@end

static double boxMuller()
{
    static double x,y;
    static bool t = NO;
    if (!t)
    {
        double u = (double)arc4random() / ARC4RANDOM_MAX;
        double v = (double)arc4random() / ARC4RANDOM_MAX;

        double r = sqrt(-2*log(u));
        double theta = 2*M_PI*v;

        x = r*cos(theta);
        y = r*sin(theta);
        t = YES;
    }
    else
    {
        x = y;
        t = NO;
    }
    return x;
}

static void MEVV(double *A, int m, int n, double *vr, double *vi, double *vecL, double *vecR)
{
    char jobvl = vecL?'V':'N', jobvr = vecR?'V':'N';
    __CLPK_integer vecLSize = vecL?n:1, vecRSize = vecR?n:1;
    __CLPK_integer rank = m;
    double *dup;
    __CLPK_integer lwork;
    double *work;
    __CLPK_integer info;

    double *wr = vr ? vr : malloc(rank * sizeof(double));
    double *wi = vi ? vi : malloc(rank * sizeof(double));

    dup = malloc(m * n * sizeof(double));
    memcpy(dup, A, m * n * sizeof(double));

    lwork = -1;
    work = malloc(sizeof(double));

    dgeev_(&jobvl, &jobvr, &rank, dup, &rank,
           wr, wi, vecL, &vecLSize, vecR, &vecRSize, work, &lwork, &info);

    assert(info == 0 && work[0] > 0);
    lwork = work[0];
    free(work);

    work = malloc(lwork *sizeof(double));

    dgeev_(&jobvl, &jobvr, &rank, dup, &rank,
           wr, wi, vecL, &vecLSize, vecR, &vecRSize, work, &lwork, &info);

    assert(info == 0);
    free(dup);
    free(work);
    if(vr == NULL) free(wr);
    if(vi == NULL) free(wi);
}

static void SVDColumnMajor(double *A, __CLPK_integer rows, __CLPK_integer columns,
                           double **s, double **u, double **vt)
{
    __CLPK_integer    i;
    __CLPK_integer    lwork, *iwork;
    double     *work;
    double     *S, *U, *Vt;
    char        achar='A';

    S = (double *) malloc(sizeof(double)*MIN(rows,columns));
    U = (double *) malloc(sizeof(double)*rows*rows);
    Vt = (double *) malloc(sizeof(double)*columns*columns);

    iwork = (__CLPK_integer *)malloc(sizeof(__CLPK_integer)*8*MIN(rows,columns));
    lwork=-1;

    work = (double *) malloc(sizeof(double)*1);

    __CLPK_integer lda = rows;
    __CLPK_integer ldu = rows;
    __CLPK_integer ldvt = columns;

    dgesdd_( &achar, &rows, &columns, A, &lda, S, U, &ldu, Vt, &ldvt, work, &lwork, iwork, &i );

    if (i != 0) {
        free(S);
        free(U);
        free(Vt);
        free(iwork);
        free(work);
        @throw [NSException exceptionWithName:@"YCMatrixException"
                                       reason:@"Error while performing SVD."
                                     userInfo:nil];
    } else {
        lwork = (int) work[0];
        free(work);
    }

    work = (double *) malloc(sizeof(double)*lwork);
    dgesdd_( &achar, &rows, &columns, A, &lda, S, U, &ldu, Vt, &ldvt, work, &lwork, iwork, &i );

    free(work);
    free(iwork);
    if (i == 0)
    {
        *s = S;
        *u = U;
        *vt = Vt;
    }
    else
    {
        free(S);
        free(U);
        free(Vt);
        @throw [NSException exceptionWithName:@"YCMatrixException"
                                       reason:@"Error while performing SVD."
                                     userInfo:nil];
    }
}

static void pInv(double *A, int rows, int columns, double *Aplus)
{
    long int    minmn;
    int    i, j, k, ii;
    double      epsilon, tolerance, maxeigen;
    double     *S = NULL, *U = NULL, *Vt = NULL;
    double     *Splus, *Splus_times_Ut;
    double *Atrans;

    epsilon = pow(2,1-56);
    tolerance = epsilon * MAX(rows,columns);
    maxeigen=-1.;

    Atrans = (double *) malloc(sizeof(double)*columns*rows);
    for ( j = 0; j < rows; j++ ) {
        for ( i = 0; i < columns; i++ ) {
            Atrans[j+i*rows] = A[i+j*columns];
        }
    }

    SVDColumnMajor(Atrans, rows, columns, &S, &U, &Vt);

    free(Atrans);

    minmn = MIN(rows,columns);

    for ( i = 0; i < minmn; i++ ) {
        maxeigen = MAX(maxeigen,S[i]);
    }

    tolerance *= maxeigen;

    Splus = (double *) malloc(sizeof(double)*columns*rows);

    Splus_times_Ut = (double *) malloc(sizeof(double)*columns*rows);

    for ( j = 0; j < rows; j++ ) {
        for ( i = 0; i < columns; i++ ) {
            if (minmn == columns) {
                ii = i;
            } else {
                ii = j;
            }
            if ( i == j && S[ii] > tolerance ) {
                Splus[i+j*columns] = 1.0 / S[ii];
            } else {
                Splus[i+j*columns] = 0.0;
            }
        }
    }

    for ( i = 0; i < columns; i++ ) {
        for ( j = 0; j < rows; j++ ) {
            Splus_times_Ut[i+j*columns] = 0.0;
            for ( k = 0; k < rows; k++ ) {
                Splus_times_Ut[i+j*columns] =
                Splus_times_Ut[i+j*columns] +
                Splus[i+k*columns] * U[j+k*rows];
            }
        }
    }

    for ( i = 0; i < columns; i++ ) {
        for ( j = 0; j < rows; j++ ) {
            Aplus[j+i*rows] = 0.0;
            for ( k = 0; k < columns; k++ ) {
                Aplus[j+i*rows] =
                Aplus[j+i*rows] +
                Vt[k+i*columns] * Splus_times_Ut[k+j*columns];
            }
        }
    }

    free(Splus);
    free(Splus_times_Ut);
    free(U);
    free(Vt);
    free(S);

    return;
}

#pragma mark - Generation of Sobol Sequences

#include <stdlib.h>
#include <math.h>

#if defined(HAVE_STDINT_H)
#  include <stdint.h>
#endif

static unsigned rightzero32(uint32_t n)
{
#if defined(__GNUC__) && \
((__GNUC__ == 3 && __GNUC_MINOR__ >= 4) || __GNUC__ > 3)
    return __builtin_ctz(~n);
#else
    const uint32_t a = 0x05f66a47;
    static const unsigned decode[32] = {0,1,2,26,23,3,15,27,24,21,19,4,12,16,28,6,31,25,22,14,20,18,11,5,30,13,17,10,29,9,8,7};
    n = ~n;
    n = a * (n & (-n));
    return decode[n >> 27];
#endif
}

static int sobol_gen(soboldata *sd, double *x)
{
    unsigned c, b, i, sdim;

    if (sd->n == 4294967295U) return 0;

    c = rightzero32(sd->n++);
    sdim = sd->sdim;
    for (i = 0; i < sdim; ++i) {
        b = sd->b[i];
        if (b >= c) {
            sd->x[i] ^= sd->m[c][i] << (b - c);
            x[i] = ((double) (sd->x[i])) / (1U << (b+1));
        }
        else {
            sd->x[i] = (sd->x[i] << (c - b)) ^ sd->m[c][i];
            sd->b[i] = c;
            x[i] = ((double) (sd->x[i])) / (1U << (c+1));
        }
    }
    return 1;
}

#include "soboldata.h"

static int sobol_init(soboldata *sd, unsigned sdim)
{
    unsigned i,j;

    if (!sdim || sdim > MAXDIM) return 0;

    sd->mdata = (uint32_t *) malloc(sizeof(uint32_t) * (sdim * 32));
    if (!sd->mdata) return 0;

    for (j = 0; j < 32; ++j) {
        sd->m[j] = sd->mdata + j * sdim;
        sd->m[j][0] = 1;
    }
    for (i = 1; i < sdim; ++i) {
        uint32_t a = sobol_a[i-1];
        unsigned d = 0, k;

        while (a) {
            ++d;
            a >>= 1;
        }
        d--;

        for (j = 0; j < d; ++j)
            sd->m[j][i] = sobol_minit[j][i-1];

        for (j = d; j < 32; ++j) {
            a = sobol_a[i-1];
            sd->m[j][i] = sd->m[j - d][i];
            for (k = 0; k < d; ++k) {
                sd->m[j][i] ^= ((a & 1) * sd->m[j-d+k][i]) << (d-k);
                a >>= 1;
            }
        }
    }

    sd->x = (uint32_t *) malloc(sizeof(uint32_t) * sdim);
    if (!sd->x) { free(sd->mdata); return 0; }

    sd->b = (unsigned *) malloc(sizeof(unsigned) * sdim);
    if (!sd->b) { free(sd->x); free(sd->mdata); return 0; }

    for (i = 0; i < sdim; ++i) {
        sd->x[i] = 0;
        sd->b[i] = 0;
    }

    sd->n = 0;
    sd->sdim = sdim;

    return 1;
}

static void sobol_destroy(soboldata *sd)
{
    free(sd->mdata);
    free(sd->x);
    free(sd->b);
}
