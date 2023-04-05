#ifndef CompatibilityMacros_h
#define CompatibilityMacros_h

#if __has_feature(nullability)
    #define ART_ASSUME_NONNULL_BEGIN      NS_ASSUME_NONNULL_BEGIN
    #define ART_ASSUME_NONNULL_END        NS_ASSUME_NONNULL_END
    #define art_nullable                  nullable
    #define art_nonnull                   nonnull
    #define art_null_resettable           null_resettable
    #define __art_nullable                __nullable
    #define __art_nonnull                 __nonnull
#else
    #define ART_ASSUME_NONNULL_BEGIN
    #define ART_ASSUME_NONNULL_END
    #define art_nullable
    #define art_nonnull
    #define art_null_resettable
    #define __art_nullable
    #define __art_nonnull
#endif

#endif /* CompatibilityMacros_h */
