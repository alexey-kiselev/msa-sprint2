package main

import (
	"net/http"
	"net/http/httptest"
	"os"
	"testing"
)

func TestPing(t *testing.T) {
	req := httptest.NewRequest(http.MethodGet, "/ping", nil)
	rr := httptest.NewRecorder()
	newMux().ServeHTTP(rr, req)
	if rr.Code != http.StatusOK {
		t.Fatalf("status %d", rr.Code)
	}
	if rr.Body.String() != "pong" {
		t.Fatalf("body %q", rr.Body.String())
	}
}

func TestHealthAndReady(t *testing.T) {
	mux := newMux()
	for _, path := range []string{"/health", "/ready"} {
		req := httptest.NewRequest(http.MethodGet, path, nil)
		rr := httptest.NewRecorder()
		mux.ServeHTTP(rr, req)
		if rr.Code != http.StatusOK {
			t.Fatalf("%s status %d", path, rr.Code)
		}
	}
}

func TestFeatureFlagOff(t *testing.T) {
	t.Setenv("ENABLE_FEATURE_X", "false")
	req := httptest.NewRequest(http.MethodGet, "/feature", nil)
	rr := httptest.NewRecorder()
	newMux().ServeHTTP(rr, req)
	if rr.Code != http.StatusNotFound {
		t.Fatalf("expected 404, got %d", rr.Code)
	}
}

func TestFeatureFlagOn(t *testing.T) {
	t.Setenv("ENABLE_FEATURE_X", "true")
	req := httptest.NewRequest(http.MethodGet, "/feature", nil)
	rr := httptest.NewRecorder()
	newMux().ServeHTTP(rr, req)
	if rr.Code != http.StatusOK {
		t.Fatalf("status %d", rr.Code)
	}
	if rr.Body.String() != "Feature X is enabled!" {
		t.Fatalf("body %q", rr.Body.String())
	}
}

func TestRootChangesWithFeatureFlag(t *testing.T) {
	os.Unsetenv("ENABLE_FEATURE_X")
	req := httptest.NewRequest(http.MethodGet, "/", nil)
	rr := httptest.NewRecorder()
	newMux().ServeHTTP(rr, req)
	if rr.Body.String() != "booking-service" {
		t.Fatalf("body %q", rr.Body.String())
	}

	t.Setenv("ENABLE_FEATURE_X", "true")
	rr = httptest.NewRecorder()
	newMux().ServeHTTP(rr, req)
	if rr.Body.String() != "booking-service: feature X enabled" {
		t.Fatalf("body %q", rr.Body.String())
	}
}
