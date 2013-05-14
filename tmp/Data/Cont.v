Require Import FP.Structures.Monad.
Require Import FP.Structures.FUnit.
Require Import FP.Structures.MonadCont.
Require Import FP.Structures.MonadTrans.
Require Import FP.Data.Function.
Require Import FP.Data.Identity.

Import FunctionNotation.
Import MonadNotation.

Inductive cont_t R (m:Type -> Type) A := ContT { un_cont_t : (A -> m R) -> m R }.
Arguments ContT {R m A} _.
Arguments un_cont_t {R m A} _ _.

Section cont_t.
  Context {m} {Monad_:Monad m}.

  Definition run_cont_t {A} (c:cont_t A m A) : m A := un_cont_t c ret.

  Context {R:Type}.

  Definition cont_t_funit {A} : A -> cont_t R m A :=
    ContT '.' apply_to.
  Global Instance cont_t_FUnit : FUnit (cont_t R m) :=
    { funit := @cont_t_funit }.

  Definition cont_t_bind {A B} (aM:cont_t R m A) (f:A -> cont_t R m B) : cont_t R m B :=
    ContT $ fun (k:B -> m R) =>
      un_cont_t aM $ fun (a:A) =>
        un_cont_t (f a) $ fun (b:B) =>
          k b.
  Global Instance cont_t_MBind : MBind (cont_t R m) :=
    { bind := @cont_t_bind }.

  Definition cont_t_callcc {A} (kk:(A -> cont_t R m R) -> cont_t R m R) : cont_t R m A :=
    ContT $ fun (k:A -> m R) =>
      run_cont_t $
        kk $ fun (a:A) =>
          ContT $ fun (kR:R -> m R) =>
            k a >>= kR.
  Global Instance cont_t_MoandCont : MonadCont R (cont_t R m) :=
    { callcc := @cont_t_callcc }.
End cont_t.

Definition cont_t_lift {R} {m} {M:Monad m} {A} (aM:m A) : cont_t R m A :=
  ContT $ fun (k:A -> m R) => aM >>= k.
Instance cont_t_MonadTrans {R} : MonadTrans (cont_t R) :=
  { lift := @cont_t_lift _ }.

Definition cont R := cont_t R identity.
Definition mk_cont {A R} (kk:(A -> R) -> R) : cont R A :=
  ContT $ fun k => Identity $ kk $ run_identity '.' k.
Definition run_cont {A} : cont A A -> A :=
  run_identity '.' run_cont_t.